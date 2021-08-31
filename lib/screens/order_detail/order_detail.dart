import 'package:demo/models/order.dart';
import 'package:demo/screens/barcode_scanner/barcode_scanner.dart';
import 'package:flutter/material.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({Key? key, required this.id, required this.title}) : super(key: key);

  final int id;
  final String title;
  static const routeName = '/order_detail';

  @override
  State<OrderDetail> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<OrderDetail> {
  void _barcodeScanner() {
    Navigator.pushNamed(context, BarcodeScanner.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final order = Order.fetchById(widget.id);

    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.title} #${widget.id}'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>
            [...order!.items.map((item) => Text(item.name))],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _barcodeScanner,
          tooltip: 'Barcode Scan',
          child: const Icon(Icons.camera_rear)
        ) // This trailing comma makes auto-formatting nicer for build methods.            
      );
  }
}
