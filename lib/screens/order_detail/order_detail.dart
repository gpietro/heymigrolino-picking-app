import 'dart:async';

import 'package:demo/models/product.dart';
import 'package:demo/models/order.dart';
import 'package:demo/screens/barcode_scanner/barcode_scanner.dart';
import 'package:demo/screens/order_detail/barcode_form.dart';
import 'package:demo/screens/order_list/order_list.dart';
import 'package:demo/state/application_state.dart';
import 'package:demo/widgets/image_full_screen_wrapper_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
      var order = appState.orders[widget.id] ??
          appState.completeOrders[widget.id]; // Avoid null exception
      return Scaffold(
        appBar: AppBar(
          title: Text('Bestellung #${order!.orderNumber}'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.edit,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    title: const Text('Insert product barcode'),
                    children: [
                      BarcodeForm(onSubmit:
                        <ScanResult>(String barcode) => appState.scanProduct(widget.id, barcode))
                    ]));
              },
            )            
          ],
        ),
        body: _productListWithScanner(order, appState.scanProduct),
      );
    });
  }

  Widget _itemBuilder(BuildContext context, Product product) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      var productImage = appState.productImages['${product.productId}'];
      var counterColor = {
        ProductStatus.available: Colors.orange,
        ProductStatus.unavailable: Colors.grey,
        ProductStatus.complete: Colors.green
      };

      var cardColor = {
        ProductStatus.unavailable: Colors.grey.shade300,
        ProductStatus.complete: Colors.green.shade100
      };

      return Slidable(
        actionPane: const SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
            key: Key('product_${product.id}'),
            child: Card(
                color: cardColor[product.status],
                child: ListTile(
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text('${product.price} CHF'),
                  trailing: Text('${product.scannedCount}/${product.quantity}',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: counterColor[product.status])),
                  leading: productImage != null
                      ? ImageFullScreenWrapperWidget(
                        child: CachedNetworkImage(
                          width: 50,
                          height: 50,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          imageUrl: productImage.src
                              .replaceAll(".jpg", "_300x300.jpg"),
                        ),
                        dark: false
                      ): null,
                ))),
        secondaryActions: <Widget>[
          if (product.status != ProductStatus.complete)
            IconSlideAction(
              caption: product.status == ProductStatus.available
                  ? 'Unavailable'
                  : 'Available',
              color: product.status == ProductStatus.available
                  ? Colors.red
                  : Colors.green,
              icon: product.status == ProductStatus.available
                  ? Icons.remove_shopping_cart_outlined
                  : Icons.add_shopping_cart_outlined,
              onTap: () => {
                appState.updateProductStatus(
                    widget.id,
                    product,
                    product.status == ProductStatus.available
                        ? ProductStatus.unavailable
                        : ProductStatus.available),
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      '${product.status == ProductStatus.unavailable ? 'Available' : 'Unavailable'}: ${product.name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          appState.updateProductStatus(
                              widget.id, product, product.status);
                        })))
              },
            ),
        ],
      );
    });
  }

  Widget _productListWithScanner(Order order, scanProduct) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      var dataCaptureContext = DataCaptureContext.forLicenseKey(
          dotenv.env['SCANDIT_LICENSE_KEY'] ?? '');
      var barcodeScanner =
          BarcodeScanner(dataCaptureContext, widget.id, scanProduct);
      var isOrderComplete = order.productIds
          .where((productId) =>
              order.products['$productId']!.status == ProductStatus.available)
          .toList()
          .isEmpty;
      return Column(children: <Widget>[
        SizedBox.fromSize(
          child: Stack(children: <Widget>[Positioned(child: barcodeScanner)]),
          size: widgets.Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.25),
        ),
        if (isOrderComplete)
          Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hurray! the order is complete',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  OutlinedButton(
                    onPressed: () async {
                      Timer timer = Timer(const Duration(milliseconds: 3000), () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          OrderList.routeName, (Route<dynamic> route) => false);
                      });
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                            Text('Order complete', style: TextStyle(fontSize: 20)),
                            Icon(
                              Icons.check_outlined,
                              color: Colors.green,
                              size: 48.0,
                            ),
                            Text('Well done!')
                          ]),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () {                                
                                Navigator.pop(context);
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  OrderList.routeName, (Route<dynamic> route) => false);
                              },
                            ),
                          ],
                        ),
                      ).then((value) {                        
                        timer.cancel();                      
                      });
                      /* 
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Order #${order.orderNumber} completed!'),
                        duration: const Duration(seconds: 2),
                      ));
                      */
                      appState.updateOrderStatus(
                          widget.id, OrderStatus.complete);
                    },
                    child: const Text('Checkout'),
                  )
                ],
              )),
        Expanded(child: _productList(order, ProductStatus.available)),
      ]);
    });
  }

  Widget _productList(Order order, ProductStatus status) {
    List<int> productIds = order.productIds
        //.where((productId) => order.products['$productId']!.status == status)
        .toList(growable: false)
      ..sort((prevId, nextId) => order.products['$prevId']!.status
          .toString()
          .compareTo(order.products['$nextId']!.status.toString()));
    // List<int> unavailableProductIds = order.productIds.where((productId) => order.products['$productId']!.status == ProductStatus.unavailable).toList();
    return ListView.builder(
        itemCount: productIds.length,
        itemBuilder: (context, index) {
          return _itemBuilder(context, order.products['${productIds[index]}']!);
        });
  }
}
