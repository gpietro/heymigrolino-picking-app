import 'package:provider/provider.dart';
import 'package:demo/screens/product_detail/product_detail.dart';
import 'package:demo/screens/product_detail/product_detail_arguments.dart';
import 'package:demo/screens/order_detail/order_detail_arguments.dart';
import 'package:demo/state/application_state.dart';
import 'package:flutter/material.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'screens/order_list/order_list.dart';
import 'screens/order_detail/order_detail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await ScanditFlutterDataCaptureBarcode.initialize();
  runApp(ChangeNotifierProvider(
      create: (context) => ApplicationState(), 
      child: const AppRouter(),   
  ));  
}

class AppRouter extends StatelessWidget {
  const AppRouter({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Bestellung auswählen',
        onGenerateRoute: _routes(),
        theme: ThemeData(primarySwatch: Colors.orange),
        // home: const MyHomePage(title: 'Pending orders'),
        home: const OrderList());
  }

  RouteFactory _routes() {
    return (settings) {
      WidgetBuilder builder;
      switch (settings.name) {
        case OrderList.routeName:
          builder = (BuildContext context) => const OrderList();
          break;
        //case BarcodeScanner.routeName:
        //  builder = (BuildContext context) => BarcodeScanner(
        //      DataCaptureContext.forLicenseKey(
        //          dotenv.env['SCANDIT_LICENSE_KEY'] ?? ''));
        //  break;
        case OrderDetail.routeName:
          final args = settings.arguments as OrderDetailArguments;
          builder = (BuildContext context) => OrderDetail(id: args.id);
          break;
        case ProductDetail.routeName:
          final args = settings.arguments as ProductDetailArguments;
          builder = (BuildContext context) => ProductDetail(
                id: args.id,
                orderId: args.orderId,
              );
          break;
        default:
          throw Exception('Invalid route: ${settings.name}');
      }
      return MaterialPageRoute<void>(builder: builder, settings: settings);
    };
  }
}
