import 'package:flutter/foundation.dart';

@immutable
class Location {
  const Location({
    required this.storeCity,
    required this.storeId,
    required this.storeMail,
    required this.storeName,
    required this.storePhone,
    required this.storeStreet,
    required this.storeZip,
    required this.zip
  });

  Location.fromJson(Map<String, Object?> json)
      : this(
          storeCity: json['storeCity']! as String,
          storeId: json['storeId']! as int,
          storeMail: json['storeMail']! as String,
          storeName: json['storeName']! as String,
          storePhone: json['storePhone']! as String,
          storeStreet: json['storeStreet']! as String,
          storeZip: json['storeZip']! as int,
          zip: json['zip']! as int,
        );

  final String storeCity;
  final int storeId;
  final String storeMail;
  final String storeName;
  final String storePhone;
  final String storeStreet;
  final int storeZip;
  final int zip;

  Map<String, Object?> toJson() {
    return {
      'storeCity': storeCity,
      'storeId': storeId,
      'storeMail': storeMail,
      'storeName': storeName,
      'storePhone': storePhone,
      'storeStreet': storeStreet,
      'storeZip': storeZip,
      'zip': zip
    };
  }
}