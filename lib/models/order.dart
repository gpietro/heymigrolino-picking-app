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
    });

    int id;
    String currency;
    int orderNumber;
    String tags;
    String totalPrice;
    int locationId;
    List<Product> products;

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        currency: json["currency"],
        orderNumber: json["orderNumber"],
        tags: json["tags"],
        totalPrice: json["totalPrice"],
        locationId: json["locationId"],
        products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "currency": currency,
        "orderNumber": orderNumber,
        "tags": tags,
        "totalPrice": totalPrice,
        "locationId": locationId,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
    };
}