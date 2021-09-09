import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/models/product.dart';
import 'package:demo/models/order.dart';
import 'package:demo/screens/barcode_scanner/barcode_scanner.dart';
import 'package:demo/state/application_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({Key? key, required this.id}) : super(key: key);

  final String id;
  static const routeName = '/order_detail';

  @override
  State<OrderDetail> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<OrderDetail> {
  bool _isCapturing = false;

  void _barcodeScanner() {
    setState(() {
      _isCapturing = !_isCapturing;
    });
    // Navigator.pushNamed(context, BarcodeScanner.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      var order = appState.orders[widget.id]!;
      return Scaffold(
          appBar: AppBar(
            title: Text('Bestellung #${order.orderNumber}'),
          ),
          body: _isCapturing
              ? _productListWithScanner(order)
              : _productList(order),
          floatingActionButton: _isCapturing
              ? null
              : FloatingActionButton(
                  onPressed: _barcodeScanner,
                  tooltip: 'Barcode Scan',
                  child: const Icon(Icons
                      .qr_code_scanner)) // This trailing comma makes auto-formatting nicer for build methods.
          );
    });
  }

  Widget _itemBuilder(BuildContext context, Product product) {
    return Consumer<ApplicationState>(builder: (context, appState, _) => 
      GestureDetector(
        onTap: () => appState.incrementScannedCounter(widget.id, product),
        key: Key('product_${product.id}'),
        child: Card(
          child: ListTile(
            title: Text(product.name),
            subtitle: Text(
                'Anzahl: ${product.quantity} (${product.price} CHF) - ${product.scannedCount}'),
          ),
        )));
  }

  Widget _productListWithScanner(Order order) {
    return Column(children: <Widget>[
      SizedBox.fromSize(
        child: Stack(children: <Widget>[
          Positioned(
              child: BarcodeScanner(DataCaptureContext.forLicenseKey(
                  dotenv.env['SCANDIT_LICENSE_KEY'] ?? '')))
        ]),
        size: widgets.Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.5),
      ),
      Expanded(child: _productList(order))
    ]);
  }

  Widget _productList(Order order) {
    return ListView.builder(
        itemCount: order.productIds.length,
        itemBuilder: (context, index) {
          return _itemBuilder(
              context, order.products['${order.productIds[index]}']!);
        });
  }
}
