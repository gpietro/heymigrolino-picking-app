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

class OrderDetail extends StatefulWidget {
  const OrderDetail({Key? key, required this.id}) : super(key: key);

  final String id;

  static const routeName = '/order_detail';

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      var order = appState.orders[widget.id]!;
      List<int> availableProductIds =
          _filterProducts(order, ProductStatus.available);
      List<int> unavailableProductIds =
          _filterProducts(order, ProductStatus.unavailable);
      return DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: AppBar(
                title: Text('Bestellung #${order.orderNumber}'),                
                /*
                bottom: TabBar(
                  tabs: [
                    const Tab(icon: Icon(Icons.list)),
                    Tab(
                        icon: Badge(
                            badgeContent:
                                Text('${unavailableProductIds.length}'),
                            badgeColor: unavailableProductIds.isEmpty
                                ? Colors.grey
                                : Colors.red,
                            child: const Icon(Icons.block))),
                  ],
                ),*/
              ),
              body: _productListWithScanner(order, appState.scanProduct),
              /*TabBarView(children: [
                _isCapturing
                    ? _productListWithScanner(order, appState.scanProduct)
                    : _productList(order, ProductStatus.available),
                _productList(order, ProductStatus.unavailable),
              ]),*/
              /*
              floatingActionButton: _isCapturing
                  ? null
                  : FloatingActionButton(
                      onPressed: _barcodeScanner,
                      tooltip: 'Barcode Scan',
                      child: const Icon(Icons
                          .qr_code_scanner)) // This trailing comma makes auto-formatting nicer for build methods.
              */
              ));
    });
  }

  Widget _itemBuilder(BuildContext context, Product product) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      var productImage = appState.productImages['${product.productId}'];
      return GestureDetector(
          onTap: () => {
                Navigator.pushNamed(context, ProductDetail.routeName,
                    arguments:
                        ProductDetailArguments('${product.id}', widget.id))
              }, // appState.incrementScannedCounter(widget.id, product),
          onPanUpdate: (details) {
            // Swiping right
            if (details.delta.dx > 0) {
              //appState.updateProductStatus(
              //    widget.id, product, ProductStatus.unavailable);
            }
            // Swiping left
            if (details.delta.dx < 0) {
              //appState.updateProductStatus(
              //    widget.id, product, ProductStatus.available);
            }
          },
          key: Key('product_${product.id}'),
          child: Card(
              child: ListTile(
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text('${product.price} CHF'),
            trailing: Text('(${product.scannedCount})${product.quantity}', style: const TextStyle(fontWeight: FontWeight.w500),),
            leading: productImage != null
                ? CachedNetworkImage(
                    width: 50,
                    height: 50,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl: productImage.src.replaceAll(".jpg", "_100x100.jpg"),
                  )
                : null,
          )));
    });
  }

  Widget _productListWithScanner(Order order, scanProduct) {
    var dataCaptureContext = DataCaptureContext.forLicenseKey(
        dotenv.env['SCANDIT_LICENSE_KEY'] ?? '');
    var barcodeScanner =
        BarcodeScanner(dataCaptureContext, widget.id, scanProduct);
    return Column(children: <Widget>[
      SizedBox.fromSize(
        child: Stack(children: <Widget>[Positioned(child: barcodeScanner)]),
        size: widgets.Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.25),
      ),
      Expanded(child: _productList(order, ProductStatus.available)),
    ]);
  }

  Widget _productList(Order order, ProductStatus status) {
    List<int> productIds = order.productIds
        .where((productId) => order.products['$productId']!.status == status)
        .toList();
    // List<int> unavailableProductIds = order.productIds.where((productId) => order.products['$productId']!.status == ProductStatus.unavailable).toList();
    return ListView.builder(
        itemCount: productIds.length,
        itemBuilder: (context, index) {
          return _itemBuilder(context, order.products['${productIds[index]}']!);
        });
  }

  Widget _unavailableProducts(Order order) {
    List<int> productIds = order.productIds
        .where((productId) =>
            order.products['$productId']!.status == ProductStatus.unavailable)
        .toList();

    return ExpansionPanelList(
      children: [
        ExpansionPanel(
          headerBuilder: (context, isOpen) {
            return const Text('Hello world');
          },
          body: const Text("Now open"),
        ),
      ],
    );
  }

  List<int> _filterProducts(Order order, ProductStatus status) {
    return order.productIds
        .where((productId) => order.products['$productId']!.status == status)
        .toList();
  }
}
