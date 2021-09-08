class Product {
  Product(
      {required this.id,
      required this.productId,
      required this.name,
      required this.price,
      required this.quantity,
      required this.sku,
      required this.scannedCount});

  int id;
  int productId;
  String name;
  String price;
  int quantity;
  String sku;
  int scannedCount;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        productId: json["productId"],
        name: json["name"],
        price: json["price"],
        quantity: json["quantity"],
        sku: json["sku"],
        scannedCount: json["scannedCount"]
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "productId": productId,
        "name": name,
        "price": price,
        "quantity": quantity,
        "sku": sku,
        "scannedCount": scannedCount
      };
}
