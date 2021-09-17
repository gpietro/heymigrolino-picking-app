enum ProductStatus { available, unavailable, complete }

class Product {
  Product(
      {required this.id,
      required this.productId,
      required this.name,
      required this.price,
      required this.quantity,
      required this.sku,
      required this.scannedCount,
      required this.status});

  int id;
  int productId;
  String name;
  String price;
  int quantity;
  String sku;
  int scannedCount;
  ProductStatus status;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
      id: json["id"],
      productId: json["productId"],
      name: json["name"],
      price: json["price"],
      quantity: json["quantity"],
      sku: json["sku"],
      scannedCount: json["scannedCount"],
      status: getStatusFromString(json["status"]));

  Map<String, dynamic> toJson() => {
        "id": id,
        "productId": productId,
        "name": name,
        "price": price,
        "quantity": quantity,
        "sku": sku,
        "scannedCount": scannedCount,
        "status": status.toString()
      };
}

ProductStatus getStatusFromString(String? statusAsString) {
  for (ProductStatus status in ProductStatus.values) {
    if (status.toString() == statusAsString) {
      return status;
    }
  }
  return ProductStatus.available;
}
