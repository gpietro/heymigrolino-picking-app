import 'package:flutter/material.dart';

enum AppNames { heymDev, heymProd, gooodsDev, gooodsProd }

class AppConfig extends InheritedWidget {
  
  const AppConfig({Key? key, required this.appName, required this.verifyBarcode, required Widget child})
      : super(key: key, child: child);

  final AppNames appName;
  final int verifyBarcode;

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}