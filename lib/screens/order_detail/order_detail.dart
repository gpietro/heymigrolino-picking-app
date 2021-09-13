import 'package:demo/models/product.dart';
import 'package:demo/models/order.dart';
import 'package:demo/screens/barcode_scanner/barcode_scanner.dart';
import 'package:demo/screens/product_detail/product_detail.dart';
import 'package:demo/screens/product_detail/product_detail_arguments.dart';
import 'package:demo/state/application_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({Key? key, required this.id}) : super(key: key);

  final String id;

  static const routeName = '/order_detail';

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
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
      return DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: AppBar(
                title: Text('Bestellung #${order.orderNumber}'),
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Badge(badgeContent: const Text('3'),child: const Icon(Icons.list))),
                    Tab(icon: Badge(badgeContent: const Text('0'),child: const Icon(Icons.block))),
                  ],
                ),
              ),
              body: TabBarView(children: [
                _isCapturing
                    ? _productListWithScanner(order, appState.scanProduct)
                    : _productList(order),
                _productList(order)
              ]),
              floatingActionButton: _isCapturing
                  ? null
                  : FloatingActionButton(
                      onPressed: _barcodeScanner,
                      tooltip: 'Barcode Scan',
                      child: const Icon(Icons
                          .qr_code_scanner)) // This trailing comma makes auto-formatting nicer for build methods.
              ));
    });
  }

  Widget _itemBuilder(BuildContext context, Product product) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      var productImage = appState.productImages['${product.productId}'];
      return GestureDetector(
          onTap: () => {
            Navigator.pushNamed(context, ProductDetail.routeName,
              arguments: ProductDetailArguments('${product.id}', widget.id))
          }, // appState.incrementScannedCounter(widget.id, product),
          onPanUpdate: (details) {
            // Swiping right
            if (details.delta.dx > 0) {
              
            }
            // Swiping left
            if (details.delta.dx < 0) {
              appState.updateProductStatus(
                  widget.id, product, ProductStatus.available);
            }
          },
          key: Key('product_${product.id}'),
          child: Card(
              child: Row(
            children: [
              if (productImage != null)
                CachedNetworkImage(
                  width: 50,
                  height: 50,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  imageUrl: productImage.src,
                ),
              Expanded(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                      'Anzahl: ${product.quantity} (${product.price} CHF) - ${product.scannedCount}'),
                ),
              )
            ],
          )));
    });
  }

  Widget _productListWithScanner(Order order, scanProduct) {
    var dataCaptureContext = DataCaptureContext.forLicenseKey(
        dotenv.env['SCANDIT_LICENSE_KEY'] ?? '');
    return Column(children: <Widget>[
      SizedBox.fromSize(
        child: Stack(children: <Widget>[
          Positioned(
              child: BarcodeScanner(dataCaptureContext, widget.id, scanProduct))
        ]),
        size: widgets.Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.5),
      ),
      Expanded(child: _productList(order))
    ]);
  }

  Widget _productList(Order order) {
    List<int> availableProductIds = order.productIds
        .where((productId) =>
            order.products['$productId']!.status == ProductStatus.available)
        .toList();
    // List<int> unavailableProductIds = order.productIds.where((productId) => order.products['$productId']!.status == ProductStatus.unavailable).toList();
    return ListView.builder(
        itemCount: availableProductIds.length,
        itemBuilder: (context, index) {
          return _itemBuilder(
              context, order.products['${availableProductIds[index]}']!);
        });
  }
}
