import 'package:barcode_widget/barcode_widget.dart';

class ProductImage {
  ProductImage(
      {required this.alt,
      required this.src,
      required this.height,
      required this.width,
      required this.barcodes,
      required this.productType});

  String alt;
  String src;
  int height;
  int width;
  List<int> barcodes;
  String productType;

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
      alt: json["alt"] ?? "",
      src: json["src"],
      height: json["height"],
      width: json['width'],
      barcodes: List<int>.from(json["barcode"].map((x) => x)),
      productType: json['productType'] ?? "");

  Map<String, dynamic> toJson() => {
        "alt": alt,
        "src": src,
        "height": height,
        "width": width,
        "barcode": List<dynamic>.from(barcodes.map((x) => x)),
        "productType": productType,
      };

  Barcode? getBarcode() {
    Barcode? result;
    switch (barcodes.first.toString().length) {
      case 14:
        result = Barcode.itf14();
        break;
      case 13:
        result = Barcode.ean13();
        break;
      case 12:
        result = Barcode.upcA();
        break;
      case 8:
        result = Barcode.ean8();
        break;
      case 6:
        result = Barcode.upcE();
        break;
      default:
        break;
    }
    return result;
  }
}
