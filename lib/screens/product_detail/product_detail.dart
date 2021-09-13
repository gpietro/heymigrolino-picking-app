import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo/models/product.dart';
import 'package:demo/state/application_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({Key? key, required this.id, required this.orderId})
      : super(key: key);

  final String id;
  final String orderId;

  static const routeName = '/product_detail';

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      var product = appState.orders[widget.orderId]!.products[widget.id]!;
      var productImage = appState.productImages['${product.productId}'];

      return Scaffold(
        appBar: AppBar(
          title: const Text('Produkt'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (productImage != null)
              CachedNetworkImage(
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                imageUrl: productImage.src,
              ),
            SizedBox(
                width: double.infinity,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(product.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)))),
            SizedBox(
                width: double.infinity,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                        'Preis: ${product.price} CHF\n\nAnzahl: ${product.scannedCount}/${product.quantity}'))),
            const Spacer(),
            // TODO: refactoring - avoid duplicated code
            if( product.status == ProductStatus.available)
              SizedBox(
                width: double.infinity,
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // background
                  onPrimary: Colors.white, // foreground
                ),
                onPressed: () {
                  appState.updateProductStatus(
                      widget.orderId, product, ProductStatus.unavailable);
                },
                child: const Text('Produkt nicht verfügbar'),
              ))),
            if( product.status == ProductStatus.unavailable)
              SizedBox(
                width: double.infinity,
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // background
                  onPrimary: Colors.white, // foreground
                ),
                onPressed: () {
                  appState.updateProductStatus(
                      widget.orderId, product, ProductStatus.available);
                },
                child: const Text('Produkt verfügbar'),
              ))),      
          ],
        ),
      );
    });
  }
}
