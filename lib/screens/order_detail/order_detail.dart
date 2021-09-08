import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/models/product.dart';
import 'package:demo/models/order.dart';
import 'package:demo/screens/barcode_scanner/barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    CollectionReference orders =
        FirebaseFirestore.instance.collection('orders');

    return FutureBuilder<DocumentSnapshot>(
        future: orders.doc(widget.id).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Scaffold(
                body: Center(child: Text('Something went wrong')));
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return const Scaffold(
                body: Center(child: Text('Order not found!')));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Order order =
                Order.fromJson(snapshot.data!.data() as Map<String, dynamic>);
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
          }
          return const Scaffold(body: Center(child: Text('Loading')));
        });
  }

  void _onTapProduct(BuildContext context, Product product) {
    product.scannedCount += 1;
    FirebaseFirestore.instance.collection('orders').doc(widget.id).update(
        {'products.${product.id}.scannedCount': FieldValue.increment(1)});
    /* Navigator.pushNamed(context, ProductDetail.routeName,
        arguments: ProductDetailArguments(productId));
    */
  }

  Widget _itemBuilder(BuildContext context, Product product) {
    return GestureDetector(
        onTap: () => _onTapProduct(context, product),
        key: Key('product_${product.id}'),
        child: Card(
          child: ListTile(
            title: Text(product.name),
            subtitle: Text(
                'Anzahl: ${product.quantity} (${product.price} CHF) - ${product.scannedCount}'),
          ),
        ));
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
