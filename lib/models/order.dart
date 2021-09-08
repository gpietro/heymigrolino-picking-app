import 'dart:convert';

import 'package:demo/models/product.dart';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
    Order({
        required this.id,
        required this.currency,
        required this.orderNumber,
        required this.tags,
        required this.totalPrice,
        required this.locationId,
        required this.products,
        required this.productIds,
    });

    int id;
    String currency;
    int orderNumber;
    String tags;
    String totalPrice;
    int locationId;
    Map<String, Product> products;
    List<int> productIds;

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        currency: json["currency"],
        orderNumber: json["orderNumber"],
        tags: json["tags"],
        totalPrice: json["totalPrice"],
        locationId: json["locationId"],
        products: Map.from(json["products"]).map((k, v) => MapEntry<String, Product>(k, Product.fromJson(v))),
        productIds: List<int>.from(json["productIds"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "currency": currency,
        "orderNumber": orderNumber,
        "tags": tags,
        "totalPrice": totalPrice,
        "locationId": locationId,
        "products": Map.from(products).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "productIds": List<dynamic>.from(productIds.map((x) => x)),
    };
}