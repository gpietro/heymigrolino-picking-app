import 'package:demo/state/application_state.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode_capture.dart';
import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';

class BarcodeScanner extends StatefulWidget {
  final DataCaptureContext dataCaptureContext;
  final String docId;
  // ignore: prefer_typing_uninitialized_variables
  final scanProduct;

  const BarcodeScanner(this.dataCaptureContext, this.docId, this.scanProduct,
      {Key? key})
      : super(key: key);

  static const routeName = '/barcode_scanner';

  // Create data capture context using your license key.
  @override
  State<StatefulWidget> createState() =>
      // ignore: no_logic_in_create_state
      _BarcodeScannerState(dataCaptureContext);
}

class _BarcodeScannerState extends State<BarcodeScanner>
    with WidgetsBindingObserver
    implements BarcodeCaptureListener {
  final DataCaptureContext _context;
  ScanResult? showScanMessage;

  // Use the world-facing (back) camera.
  final Camera? _camera = Camera.defaultCamera;
  late BarcodeCapture _barcodeCapture;
  late DataCaptureView _captureView;

  bool _isPermissionMessageVisible = false;

  _BarcodeScannerState(this._context);

  void _checkPermission() {
    Permission.camera.request().isGranted.then((value) => setState(() {
          _isPermissionMessageVisible = !value;
          if (value) {
            _camera?.switchToDesiredState(FrameSourceState.on);
          }
        }));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    // Use the recommended camera settings for the BarcodeCapture mode.
    _camera?.applySettings(BarcodeCapture.recommendedCameraSettings);

    // Switch camera on to start streaming frames and enable the barcode tracking mode.
    // The camera is started asynchronously and will take some time to completely turn on.
    _checkPermission();

    // The barcode capture process is configured through barcode capture settings
    // which are then applied to the barcode capture instance that manages barcode capture.
    var captureSettings = BarcodeCaptureSettings();

    // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
    // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
    // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
    captureSettings.enableSymbologies({
      Symbology.ean8,
      Symbology.ean13Upca,
      Symbology.upce,
      Symbology.interleavedTwoOfFive
    });

    captureSettings
        .settingsForSymbology(Symbology.ean13Upca)
        .setExtensionEnabled("remove_leading_upca_zero", enabled: true);

    // Some linear/1d barcode symbologies allow you to encode variable-length data. By default, the Scandit
    // Data Capture SDK only scans barcodes in a certain length range. If your application requires scanning of one
    // of these symbologies, and the length is falling outside the default range, you may need to adjust the "active
    // symbol counts" for this symbology. This is shown in the following few lines of code for one of the
    // variable-length symbologies.

    //captureSettings.settingsForSymbology(Symbology.code39).activeSymbolCounts =
    //    {for (var i = 7; i <= 20; i++) i};

    // Create new barcode capture mode with the settings from above.
    _barcodeCapture = BarcodeCapture.forContext(_context, captureSettings)
      // Register self as a listener to get informed whenever a new barcode got recognized.
      ..addListener(this);

    // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
    // camera preview. The view must be connected to the data capture context.
    _captureView = DataCaptureView.forContext(_context);

    // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
    // the video preview. This is optional, but recommended for better visual feedback.
    var overlay = BarcodeCaptureOverlay.withBarcodeCaptureForView(
        _barcodeCapture, _captureView)
      ..viewfinder = RectangularViewfinder.withStyleAndLineStyle(
          RectangularViewfinderStyle.square,
          RectangularViewfinderLineStyle.light);

    // Adjust the overlay's barcode highlighting to match the new viewfinder styles and improve the visibility of feedback.
    // With 6.10 we will introduce this visual treatment as a new style for the overlay.
    overlay.brush = Brush(const Color.fromARGB(0, 0, 0, 0),
        const Color.fromARGB(255, 255, 255, 255), 3);

    _captureView.addOverlay(overlay);

    // Set the default camera as the frame source of the context. The camera is off by
    // default and must be turned on to start streaming frames to the data capture context for recognition.
    if (_camera != null) {
      _context.setFrameSource(_camera!);
    }
    // TODO: Enable camera on tap
    _camera?.switchToDesiredState(FrameSourceState.on);
    _barcodeCapture.isEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children;
    if (_isPermissionMessageVisible) {
      children = [
        PlatformText('No permission to access the camera!',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black))
      ];
    } else {
      children = [_captureView];
    }
    if (showScanMessage != null) {
      String textMessage;
      Color color;
      if (showScanMessage == ScanResult.ok) {
        textMessage = 'PRODUKT GESCANNT!';
        color = const Color(0xAA43a047);
      } else if (showScanMessage == ScanResult.full) {
        textMessage = 'PRODUKT SCHON GESCANNT!';
        color = const Color(0xAAe53935);
      } else {
        textMessage = 'FALSCHES PRODUKT!';
        color = const Color(0xAAe53935);
      }
      children = [
        ...children,
        // TODO: try to use Positioned.fill instead of Container
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
            ),
            child: Text(
              textMessage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ))
      ];
    }

    return Stack(alignment: const Alignment(0, 0), children: children);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    } else if (state == AppLifecycleState.paused) {
      _camera?.switchToDesiredState(FrameSourceState.off);
    }
  }

  @override
  void didScan(
      BarcodeCapture barcodeCapture, BarcodeCaptureSession session) async {
    _barcodeCapture.isEnabled = false;
    var code = session.newlyRecognizedBarcodes.first;
    var data = (code.data == null || code.data?.isEmpty == true)
        ? code.rawData
        : code.data;
    ScanResult scanResult = await widget.scanProduct(widget.docId, data);
    ApplicationState.analytics.logEvent(name: "picking_tracking", parameters: {
      "action": "scan-product",
      "result": scanResult.toString(),
      "orderId": widget.docId,
      "barcode": data
    });
    setState(() {
      showScanMessage = scanResult;
    });

    Future.delayed(
        const Duration(seconds: 2),
        () => {
              _barcodeCapture.isEnabled = true,
              setState(() {
                showScanMessage = null;
              })
            });
  }

  @override
  void didUpdateSession(
      BarcodeCapture barcodeCapture, BarcodeCaptureSession session) {}

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _barcodeCapture.removeListener(this);
    _barcodeCapture.isEnabled = false;
    _camera?.switchToDesiredState(FrameSourceState.off);
    _context.removeAllModes();
    super.dispose();
  }
}
