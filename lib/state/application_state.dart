import 'dart:async';
import 'package:demo/models/order.dart';
import 'package:demo/models/product.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Map<String, Order> _orders = {};

  Future<void> init() async {
    await Firebase.initializeApp();

    // TODO: handle unsubscribe when user is loggedin
    FirebaseFirestore.instance
        .collection('orders')
        .snapshots()
        .listen((snapshot) {
      _orders = {};
      for (final document in snapshot.docs) {
        _orders[document.reference.id] = Order.fromJson(document.data());
      }
      notifyListeners();
    });
  }

  Future<void> scanProduct(String docId, String sku) async {
    Product? scannedProduct;
    _orders[docId]!.products.forEach((_, product) {
      if (product.sku == sku) {
        scannedProduct = product;
      }
    });
    if (scannedProduct != null) {
      incrementScannedCounter(docId, scannedProduct!);
    }
  }

  Future<void> incrementScannedCounter(String docId, Product product) async {
    if (product.scannedCount < product.quantity) {
      return FirebaseFirestore.instance.collection('orders').doc(docId).update(
          {'products.${product.id}.scannedCount': FieldValue.increment(1)});
    }
  }

  Map<String, Order> get orders => _orders;
}
