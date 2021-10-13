import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:demo/models/product.dart';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

enum OrderStatus { active, complete, verified }

class Order {
  Order({
    required this.id,
    required this.currency,
    required this.orderNumber,
    required this.customerName,
    required this.tags,
    required this.totalPrice,
    required this.locationId,
    required this.createdAt,
    required this.updatedAt,
    required this.products,
    required this.productIds,
    required this.status,
  });

  int id;
  String currency;
  int orderNumber;
  String? customerName;
  String tags;
  String totalPrice;
  int locationId;
  int createdAt;
  int updatedAt;
  Map<String, Product> products;
  List<int> productIds;
  OrderStatus status;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        currency: json["currency"],
        orderNumber: json["orderNumber"],
        customerName: json["customerName"],
        tags: json["tags"],
        totalPrice: json["totalPrice"],
        locationId: json["locationId"],
        createdAt: json["createdAt"],
        updatedAt: json['updatedAt'],
        products: Map.from(json["products"])
            .map((k, v) => MapEntry<String, Product>(k, Product.fromJson(v))),
        productIds: List<int>.from(json["productIds"].map((x) => x)),
        status: getStatusFromString(json["status"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "currency": currency,
        "orderNumber": orderNumber,
        "customerName": customerName,
        "tags": tags,
        "totalPrice": totalPrice,
        "locationId": locationId,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "products": Map.from(products)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "productIds": List<dynamic>.from(productIds.map((x) => x)),
        "status": status.toString()
      };

  String createdTime() {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(createdAt);
    var format = DateFormat("HH:mm");
    return format.format(date);
  }
}

OrderStatus getStatusFromString(String? statusAsString) {
  for (OrderStatus element in OrderStatus.values) {
    if (element.toString() == statusAsString) {
      return element;
    }
  }
  return OrderStatus.active;
}
