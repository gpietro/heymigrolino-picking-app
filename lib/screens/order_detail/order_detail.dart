import 'package:demo/models/product.dart';
import 'package:demo/models/order.dart';
import 'package:demo/models/product_image.dart';
import 'package:demo/screens/bags_selection/bags_selection.dart';
import 'package:demo/screens/bags_selection/bags_selection_arguments.dart';
import 'package:demo/widgets/barcode_scanner.dart';
import 'package:demo/screens/order_detail/barcode_form.dart';
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
                            title: const Text('Nummer des Barcodes eingeben'),
                            children: [
                              BarcodeForm(
                                  onSubmit: <ScanResult>(String barcode) =>
                                      appState.scanProduct(widget.id, barcode))
                            ]));
              },
            )
          ],
        ),
        body: _productListWithScanner(order, appState.scanProduct),
      );
    });
  }

  Widget _itemBuilder(
      BuildContext context, int index, Order order, List<int> productIds) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      Product product = order.products['${productIds[index]}']!;
      var productImage = appState.productImages['${product.productId}'];
      var previousType = '';
      Product? previousProduct;
      if (index > 0) {
        previousProduct = order.products['${productIds[index - 1]}']!;
        previousType =
            appState.productImages['${previousProduct.productId}']!.productType;
      }

      if (product.status == ProductStatus.complete &&
          previousProduct != null &&
          previousProduct.status != ProductStatus.complete) {
        return Column(children: [
          _completeHeader(),
          _listItem(
              product,
              productImage!,
              appState.updateProductStatus,
              appState.incrementScannedCounter,
              appState.decrementScannedCounter)
        ]);
      } else if (product.status == ProductStatus.unavailable &&
          previousProduct != null &&
          previousProduct.status != ProductStatus.unavailable) {
        return Column(children: [
          _unavailableHeader(),
          _listItem(
              product,
              productImage!,
              appState.updateProductStatus,
              appState.incrementScannedCounter,
              appState.decrementScannedCounter)
        ]);
      } else if (product.status == ProductStatus.available &&
          (index == 0 || productImage!.productType != previousType)) {
        return Column(children: [
          _listHeader(productImage!),
          _listItem(
              product,
              productImage,
              appState.updateProductStatus,
              appState.incrementScannedCounter,
              appState.decrementScannedCounter)
        ]);
      }
      return _listItem(product, productImage!, appState.updateProductStatus,
          appState.incrementScannedCounter, appState.decrementScannedCounter);
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
        if (!isOrderComplete)
          SizedBox.fromSize(
            child: Stack(children: <Widget>[Positioned(child: barcodeScanner)]),
            size: widgets.Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height * 0.25),
          ),
        if (isOrderComplete)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: ElevatedButton(
                  onPressed: () {
                    ApplicationState.analytics.logEvent(
                        name: "picking_tracking",
                        parameters: {
                          "action": "checkout",
                          "orderId": widget.id,
                          "orderNumber": order.orderNumber
                        });
                    Navigator.pushNamed(context, BagsSelection.routeName,
                        arguments: BagsSelectionArguments(
                            widget.id, order.locationId));
                  },
                  child: const Text('ZUR KASSE'),
                ),
              ),
              SizedBox(
                  width: double.infinity,
                  child: Card(
                    margin: const EdgeInsets.all(0),
                    color: Colors.orange.shade200,
                    child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, top: 5.0, bottom: 5.0, right: 15.0),
                        child: Text("Die Bestellung ist abgeschlossen",
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ))),
                  ))
            ],
          ),
        Expanded(
            child: _productList(
                order, ProductStatus.available, appState.productImages)),
      ]);
    });
  }

  Widget _productList(Order order, ProductStatus status,
      Map<String, ProductImage> productImages) {
    List<int> productIds = order.productIds.toList(growable: false)
      ..sort((prevId, nextId) {
        String productTypeA =
            productImages['${order.products['$prevId']?.productId}']
                    ?.productType ??
                '';
        String productTypeB =
            productImages['${order.products['$nextId']?.productId}']
                    ?.productType ??
                '';
        return productTypeA.compareTo(productTypeB);
      })
      ..sort((prevId, nextId) => order.products['$prevId']!.status
          .toString()
          .compareTo(order.products['$nextId']!.status.toString()));
    return ListView.builder(
        itemCount: productIds.length,
        itemBuilder: (context, index) {
          return _itemBuilder(context, index, order, productIds);
        });
  }

  Widget _completeHeader() {
    return SizedBox(
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.all(0),
          color: Colors.green.shade200,
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, top: 5.0, bottom: 5.0, right: 15.0),
              child: Text("Eingekaufte Produkte",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ))),
        ));
  }

  Widget _unavailableHeader() {
    return SizedBox(
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.all(0),
          color: Colors.grey.shade200,
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, top: 5.0, bottom: 5.0, right: 15.0),
              child: Text("Nicht verfügbare Produkte",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ))),
        ));
  }

  Widget _listHeader(ProductImage productImage) {
    return SizedBox(
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.all(0),
          color: Colors.grey.shade200,
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, top: 5.0, bottom: 5.0, right: 15.0),
              child: Text(productImage.productType.split('. ').last,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ))),
        ));
  }

  Widget _listItem(Product product, ProductImage? productImage,
      updateProductStatus, incrementScannedCounter, decrementScannedCounter) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Slidable(
          actionPane: const SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: _productRow(product, productImage),
          actions: _leftSwipeActions(product, incrementScannedCounter),
          secondaryActions: _rightSwipeActions(
              product, updateProductStatus, decrementScannedCounter),
        ));
  }

  Widget _productRow(Product product, ProductImage? productImage) {
    var cardColor = {
      ProductStatus.unavailable: Colors.grey.shade300,
      ProductStatus.complete: Colors.green.shade100
    };

    var counterColor = {
      ProductStatus.available: Colors.orange,
      ProductStatus.unavailable: Colors.grey,
      ProductStatus.complete: Colors.green
    };

    return Container(
        key: Key('product_${product.id}'),
        child: Card(
            margin: const EdgeInsets.all(0),
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
                      fontSize: 20,
                      color: counterColor[product.status])),
              leading: productImage != null
                  ? ImageFullScreenWrapperWidget(
                      child: CachedNetworkImage(
                        width: 50,
                        height: 50,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        imageUrl:
                            productImage.src.replaceAll(".jpg", "_300x300.jpg"),
                      ),
                      dark: false)
                  : null,
            )));
  }

  List<Widget> _leftSwipeActions(Product product, incrementScannedCounter) {
    if (product.status == ProductStatus.available) {
      if (product.scannedCount > 0) {
        return [
          IconSlideAction(
            caption: 'Hinzufügen',
            color: Colors.green,
            icon: Icons.add,
            onTap: () => {
              incrementScannedCounter(widget.id, product),
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text(
                    'Produkt hinzugefügt: ${product.name}',
                    overflow: TextOverflow.ellipsis,
                  )))
            },
          )
        ];
      }
    }
    return [];
  }

  List<Widget> _rightSwipeActions(
      Product product, updateProductStatus, decrementScannedCounter) {
    if (product.status == ProductStatus.available) {
      if (product.scannedCount == 0) {
        return [
          IconSlideAction(
            caption: 'Nicht verfügbar',
            color: Colors.red,
            icon: Icons.remove_shopping_cart_outlined,
            onTap: () => {
              updateProductStatus(
                  widget.id, product, ProductStatus.unavailable),
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text(
                    'Nicht verfügbar: ${product.name}',
                    overflow: TextOverflow.ellipsis,
                  )))
            },
          )
        ];
      } else {
        return [
          IconSlideAction(
            caption: 'Entfernen',
            color: Colors.orange,
            icon: Icons.remove,
            onTap: () => {
              decrementScannedCounter(widget.id, product),
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text(
                    'Entfernt: ${product.name}',
                    overflow: TextOverflow.ellipsis,
                  )))
            },
          ),
          IconSlideAction(
            caption: 'Fertig',
            color: Colors.green,
            icon: Icons.check,
            onTap: () => {
              updateProductStatus(
                  widget.id, product, ProductStatus.unavailable),
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text(
                    'Produkt fertig: ${product.name}',
                    overflow: TextOverflow.ellipsis,
                  )))
            },
          )
        ];
      }
    }
    if (product.status == ProductStatus.unavailable) {
      return [
        IconSlideAction(
          caption: 'verfügbar',
          color: Colors.green,
          icon: Icons.add_shopping_cart_outlined,
          onTap: () => {
            updateProductStatus(widget.id, product, ProductStatus.available),
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: const Duration(seconds: 1),
                content: Text(
                  'verfügbar: ${product.name}',
                  overflow: TextOverflow.ellipsis,
                )))
          },
        )
      ];
    }
    // else status complete
    return [
      IconSlideAction(
        caption: 'Entfernen',
        color: Colors.orange,
        icon: Icons.remove,
        onTap: () => {
          decrementScannedCounter(widget.id, product),
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 1),
              content: Text(
                'Entfernt: ${product.name}',
                overflow: TextOverflow.ellipsis,
              )))
        },
      )
    ];
  }
}
