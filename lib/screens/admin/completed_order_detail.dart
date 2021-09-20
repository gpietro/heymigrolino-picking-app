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
      var order = appState.completeOrders[widget.id]!;
      return DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: AppBar(
                title: Text('#${order.orderNumber} Bestellung'),                                
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              body: _productList(order)              
              ));
    });
  }

  Widget _itemBuilder(BuildContext context, Product product) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      // var productImage = appState.productImages['${product.productId}'];
      return Card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                /*
                if(productImage != null)
                  CachedNetworkImage(
                    width: 50,
                    height: 50,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl: productImage.src.replaceAll(".jpg", "_100x100.jpg"),
                  ),
                */
                Expanded(
                child: Padding( 
                  padding: const EdgeInsets.all(5.0), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,                  
                    children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text('${product.price} CHF - Anzahl: ${product.quantity}(${product.scannedCount})')
                  ]))),
                Padding( 
                  padding: const EdgeInsets.all(5.0), 
                  child: 
                    BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: product.sku,
                    width: 120,
                    style: const TextStyle(fontSize: 10)
                  )
                )               
              ])              
            );
    });
  }

  Widget _productList(Order order) {
    List<int> productIds = order.productIds
        .toList();
    // List<int> unavailableProductIds = order.productIds.where((productId) => order.products['$productId']!.status == ProductStatus.unavailable).toList();
    return ListView.builder(
        itemCount: productIds.length,
        itemBuilder: (context, index) {
          return _itemBuilder(context, order.products['${productIds[index]}']!);
        });
  }
}