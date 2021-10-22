import 'dart:async';
import 'package:demo/models/order.dart';
import 'package:demo/models/order_location.dart';
import 'package:demo/models/product.dart';
import 'package:demo/models/product_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wakelock/wakelock.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

enum ScanResult { ok, full, error }

bool matchProduct(ProductImage? productImage, Product product, String barcode) {
  if (productImage == null) {
    return false;
  }
  var barcodes = productImage.barcodes.map((barcode) => barcode.toString());
  if (productImage.isWeighted) {
    barcodes = barcodes.map((barcode) => barcode.substring(0, 7));
    barcode = barcode.substring(0, 7);
  }
  if (barcodes.contains(barcode)) {
    return true;
  }
  return false;
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  Map<String, Order> _completeOrders = {};
  Map<String, Order> _activeOrders = {};
  Map<String, ProductImage> _productImages = {};
  List<OrderLocation> _orderLocations = [];
  OrderLocation? selectedLocation;

  Future<void> init() async {
    await Firebase.initializeApp();
    await FirebaseAuth.instance.signInAnonymously();
    // !Does not support Firestore yet!
    // await FirebaseAppCheck.instance.activate(webRecaptchaSiteKey: 'recaptcha-v3-site-key');
    Wakelock.enable();    

    // Active orders
    FirebaseFirestore.instance
        .collection('orders')
        .where("status", isEqualTo: OrderStatus.active.toString())
        .orderBy("orderNumber", descending: true)
        .snapshots()
        .listen((snapshot) {
      _activeOrders = {};
      for (final document in snapshot.docs) {
        _activeOrders[document.reference.id] = Order.fromJson(document.data());
      }
      notifyListeners();
    });

    // Complete orders
    FirebaseFirestore.instance
        .collection('orders')
        .where("status", isEqualTo: OrderStatus.complete.toString())
        .orderBy("orderNumber", descending: true)
        .snapshots()
        .listen((snapshot) {
      _completeOrders = {};
      for (final document in snapshot.docs) {
        _completeOrders[document.reference.id] =
            Order.fromJson(document.data());
      }
      notifyListeners();
    });

    FirebaseFirestore.instance
        .collection('product-images')
        .snapshots()
        .listen((snapshot) {
      _productImages = {};
      for (final document in snapshot.docs) {
        _productImages[document.reference.id] =
            ProductImage.fromJson(document.data());
      }
      notifyListeners();
    });

    FirebaseFirestore.instance
        .collection('locations')
        .snapshots()
        .listen((snapshot) {
      _orderLocations = [];
      for (final document in snapshot.docs) {
        _orderLocations.add(OrderLocation.fromJson(document.data()));
      }
      selectedLocation = _orderLocations.first;
      notifyListeners();
    });
  }

  Future<ScanResult> scanProduct(String docId, String barcode) async {
    Product? scannedProduct;
    _activeOrders[docId]!.products.forEach((_, product) {
      var productImage = _productImages['${product.productId}'];
      if (matchProduct(productImage, product, barcode)) {
        scannedProduct = product;
      }
    });
    if (scannedProduct != null) {
      if (scannedProduct!.scannedCount < scannedProduct!.quantity) {
        await incrementScannedCounter(docId, scannedProduct!);
        if (scannedProduct!.quantity - scannedProduct!.scannedCount == 1) {
          updateProductStatus(docId, scannedProduct!, ProductStatus.complete);
        }
        return ScanResult.ok;
      }
      return ScanResult.full;
    }
    return ScanResult.error;
  }

  Future<void> updateProductStatus(
      String docId, Product product, ProductStatus status) {
    return FirebaseFirestore.instance
        .collection('orders')
        .doc(docId)
        .update({'products.${product.id}.status': status.toString()});
  }

  Future<void> updateOrderStatus(String docId, OrderStatus status) {
    return FirebaseFirestore.instance
        .collection('orders')
        .doc(docId)
        .update({'status': status.toString()});
  }

  Future<void> updateOrderBags(String docId, int orderNumber, int locationId,
      int counterBags, int counterFBags) {
    return FirebaseFirestore.instance.collection('order-bags')
      .doc(orderNumber.toString())
      .set({
        'orderNumber': orderNumber,
        'locationId': locationId,
        'bags': counterBags,
        'frozenBags': counterFBags
      });
  }

  Future<void> incrementScannedCounter(String docId, Product product) async {
    return FirebaseFirestore.instance.collection('orders').doc(docId).update(
        {'products.${product.id}.scannedCount': FieldValue.increment(1)});
  }

  // by default: active orders
  Map<String, Order> get orders => _activeOrders;
  Map<String, Order> get completeOrders => _completeOrders;
  Map<String, ProductImage> get productImages => _productImages;
  List<OrderLocation> get orderLocations => _orderLocations;  
}
