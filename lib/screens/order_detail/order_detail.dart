import 'package:demo/models/item.dart';
import 'package:demo/models/order.dart';
import 'package:demo/screens/barcode_scanner/barcode_scanner.dart';
import 'package:demo/screens/item_detail/item_detail.dart';
import 'package:demo/screens/item_detail/item_detail_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({Key? key, required this.id, required this.title})
      : super(key: key);

  final int id;
  final String title;
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
    final order = Order.fetchById(widget.id);
    final _scannedItemCounter = <int, int>{};

    if (order != null) {
      for (var item in order.items) {
        setState(() {
          _scannedItemCounter[item.id] = 0;
        });
      }

      debugPrint('rendering $_scannedItemCounter');
      return Scaffold(
          appBar: AppBar(
            title: Text('${widget.title} #${widget.id}'),
          ),
          body: _isCapturing ? _itemListWithScanner(order) : _itemList(order),
          floatingActionButton: _isCapturing
              ? null
              : FloatingActionButton(
                  onPressed: _barcodeScanner,
                  tooltip: 'Barcode Scan',
                  child: const Icon(Icons
                      .qr_code_scanner)) // This trailing comma makes auto-formatting nicer for build methods.
          );
    }
    return const Scaffold(body: Center(child: Text('Order not found!')));
  }

  void _onTapItem(BuildContext context, int itemId) {
    Navigator.pushNamed(context, ItemDetail.routeName,
        arguments: ItemDetailArguments(itemId));
  }

  Widget _itemBuilder(BuildContext context, Item item) {
    return GestureDetector(
        onTap: () => _onTapItem(context, item.id),
        key: Key('item_${item.id}'),
        child: Card(
          child: ListTile(
            title: Text(item.name),
            subtitle: Text('Anzahl: ${item.quantity} (${item.price} CHF)'),
          ),
        ));
  }

  Widget _itemListWithScanner(Order order) {
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
      Expanded(child: _itemList(order))
    ]);
  }

  Widget _itemList(Order order) {
    return ListView.builder(
        itemCount: order.items.length,
        itemBuilder: (context, index) {
          return _itemBuilder(context, order.items[index]);
        });
  }
}
