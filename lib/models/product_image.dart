class ProductImage {
  ProductImage({
    required this.alt,
    required this.src,
    required this.height,
    required this.width
  });

  String alt;
  String src;
  int height;
  int width;

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
    alt: json["alt"] ?? "",
    src: json["src"],
    height: json["height"],
    width: json['width']
  );

  Map<String, dynamic> toJson() => {
    "alt": alt,
    "src": src,
    "height": height,
    "width": width
  };
}
