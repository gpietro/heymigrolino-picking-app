class OrderLocation {
  OrderLocation({required this.id, required this.name, required this.zip});

  int id;
  String name;
  String zip;

  factory OrderLocation.fromJson(Map<String, dynamic> json) => OrderLocation(
        id: json["id"],
        name: json["name"],
        zip: json["zip"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "zip": zip
      };
}
