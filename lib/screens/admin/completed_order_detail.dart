import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo/models/product.dart';
import 'package:demo/models/order.dart';
import 'package:demo/state/application_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';

class CompletedOrderDetail extends StatefulWidget {
  const CompletedOrderDetail({Key? key, required this.id}) : super(key: key);

  final String id;

  static const routeName = '/completed_order_detail';

  @override
  State<CompletedOrderDetail> createState() => _CompletedOrderDetailState();
}

class _CompletedOrderDetailState extends State<CompletedOrderDetail> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      var order = appState.completeOrders[widget.id];
      if (order != null) {
        return Scaffold(
            appBar: AppBar(
              title: Text('#${order.orderNumber} Bestellung'),
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
            ),
            body: _productList(
                order,
                () => appState.updateOrderStatus(
                    widget.id, OrderStatus.verified)));
      }
      // TODO: avoid this render when deleting object
      return Scaffold(
          appBar: AppBar(
            title: const Text('Order not found'),
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
          body: Column(
              children: [Text('Order with id #${widget.id} not found')]));
    });
  }

  Widget _itemBuilder(BuildContext context, Product product) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      var productImage = appState.productImages['${product.productId}'];
      return Card(
          child: Column(children: [
        if (product.scannedCount > 0)
          Row(
            children: [
              if (productImage != null)
                CachedNetworkImage(
                  width: 50,
                  height: 50,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  imageUrl: productImage.src.replaceAll(".jpg", "_100x100.jpg"),
                ),
              Text(
                '${product.scannedCount} x ${product.name}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              )
            ],
          ),
        if (product.scannedCount > 0)
          BarcodeWidget(
              barcode: productImage!.getBarcode()!,
              data: productImage.barcode,
              width: 150,
              style: const TextStyle(fontSize: 10))
      ]));
    });
  }

  Widget _productList(Order order, Function deleteOrder) {
    List<int> productIds = order.productIds.toList();
    // List<int> unavailableProductIds = order.productIds.where((productId) => order.products['$productId']!.status == ProductStatus.unavailable).toList();
    return ListView.builder(
        itemCount: productIds.length + 1,
        itemBuilder: (context, index) {
          if (index == productIds.length) {
            return SizedBox(
                width: double.infinity,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Timer timer =
                            Timer(const Duration(milliseconds: 3000), () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.of(context).pop();
                          deleteOrder();
                        });
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) => AlertDialog(
                            content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('Order verified',
                                      style: TextStyle(fontSize: 20)),
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
                                  Navigator.of(context).pop();
                                  deleteOrder();
                                },
                              ),
                            ],
                          ),
                        ).then((value) {
                          timer.cancel();
                        });
                        /*
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Order #${order.orderNumber} verified!'),
                          duration: const Duration(seconds: 2),
                        ));
                        */                        
                      },
                      child: const Text('Order verified'),
                    )));
          }
          return _itemBuilder(context, order.products['${productIds[index]}']!);
        });
  }
}
