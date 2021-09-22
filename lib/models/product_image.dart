class ProductImage {
  ProductImage(
      {required this.alt,
      required this.src,
      required this.height,
      required this.width,
      required this.barcode});

  String alt;
  String src;
  int height;
  int width;
  String barcode;

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
      alt: json["alt"] ?? "",
      src: json["src"],
      height: json["height"],
      width: json['width'],
      barcode: json['barcode']);

  Map<String, dynamic> toJson() =>
      {"alt": alt, "src": src, "height": height, "width": width, "barcode": barcode};
}
