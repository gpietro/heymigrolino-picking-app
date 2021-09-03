import 'package:demo/screens/barcode_scanner/barcode_scanner.dart';
import 'package:demo/screens/item_detail/item_detail.dart';
import 'package:demo/screens/item_detail/item_detail_arguments.dart';
import 'package:demo/screens/order_detail/order_detail_arguments.dart';
import 'package:flutter/material.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';
import 'screens/order_list/order_list.dart';
import 'screens/order_detail/order_detail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await ScanditFlutterDataCaptureBarcode.initialize();
  runApp(const PickingApp());
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
class PickingApp extends StatefulWidget {
  const PickingApp({Key? key}) : super(key: key);

  // Create the initialization Future outside of `build`:
  @override
  _PickingAppState createState() => _PickingAppState();
}

class _PickingAppState extends State<PickingApp> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return const Center(
            child: Text("Something went wrong", textDirection: TextDirection.ltr)            
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return const MyAwesomeApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return const Center(
            child: Text("Loading", textDirection: TextDirection.ltr)            
          );
      },
    );
  }
}

class MyAwesomeApp extends StatelessWidget {
  const MyAwesomeApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Bestellung auswählen',
        onGenerateRoute: _routes(),
        theme: ThemeData(primarySwatch: Colors.orange),
        // home: const MyHomePage(title: 'Pending orders'),
        home: const OrderList());
  }

  RouteFactory _routes() {
    return (settings) {
      WidgetBuilder builder;
      switch (settings.name) {
        case OrderList.routeName:
          builder = (BuildContext context) => const OrderList();
          break;
        case BarcodeScanner.routeName:
          builder = (BuildContext context) => BarcodeScanner(
              DataCaptureContext.forLicenseKey(
                  dotenv.env['SCANDIT_LICENSE_KEY'] ?? ''));
          break;
        case OrderDetail.routeName:
          final args = settings.arguments as OrderDetailArguments;
          builder = (BuildContext context) =>
              OrderDetail(id: args.id, title: 'Bestellung');
          break;
        case ItemDetail.routeName:
          final args = settings.arguments as ItemDetailArguments;
          builder = (BuildContext context) => ItemDetail(
                id: args.id,
                name: 'Coca Cola',
                price: 1.50,
                quantity: 3,
              ); // Faking data
          break;
        default:
          throw Exception('Invalid route: ${settings.name}');
      }
      return MaterialPageRoute<void>(builder: builder, settings: settings);
    };
  }
}
