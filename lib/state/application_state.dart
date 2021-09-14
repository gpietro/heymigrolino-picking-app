import 'dart:async';
import 'package:demo/models/order.dart';
import 'package:demo/models/product.dart';
import 'package:demo/models/product_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Map<String, Order> _completeOrders = {};
  Map<String, Order> _activeOrders = {};
  Map<String, ProductImage> _productImages = {};

  Future<void> init() async {
    await Firebase.initializeApp();

    // Active orders
    FirebaseFirestore.instance
        .collection('orders')
        .where("status", isEqualTo: OrderStatus.active.toString())
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
  }

  Future<void> scanProduct(String docId, String sku) async {
    Product? scannedProduct;
    _activeOrders[docId]!.products.forEach((_, product) {
      if (product.sku == sku && product.status == ProductStatus.available) {
        scannedProduct = product;
      }
    });
    if (scannedProduct != null) {
      incrementScannedCounter(docId, scannedProduct!);
    }
  }

  Future<void> updateProductStatus(
      String docId, Product product, ProductStatus status) {
    return FirebaseFirestore.instance
        .collection('orders')
        .doc(docId)
        .update({'products.${product.id}.status': status.toString()});
  }

  Future<void> incrementScannedCounter(String docId, Product product) async {
    if (product.scannedCount < product.quantity) {
      return FirebaseFirestore.instance.collection('orders').doc(docId).update(
          {'products.${product.id}.scannedCount': FieldValue.increment(1)});
    }
  }

  // by default: active orders
  Map<String, Order> get orders => _activeOrders;
  Map<String, Order> get completeOrders => _completeOrders;
  Map<String, ProductImage> get productImages => _productImages;
}
