import 'package:demo/screens/order_detail/order_detail_arguments.dart';
import 'package:flutter/material.dart';
import 'screens/order_list/order_list.dart';
import 'screens/order_detail/order_detail.dart';

void main() {
  runApp(const MyApp());
}

const orderListRoute = '/';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Gooods pending orders',
        onGenerateRoute: _routes(),
        theme: ThemeData(primarySwatch: Colors.red),
        // home: const MyHomePage(title: 'Pending orders'),
        home: const OrderList());
  }

  RouteFactory _routes() {
    return (settings) {
      WidgetBuilder builder;
      switch (settings.name) {
        case orderListRoute:
          builder = (BuildContext context) => const OrderList();
          break;
        case OrderDetail.routeName:
          final args = settings.arguments as OrderDetailArguments;
          builder = (BuildContext context) => OrderDetail(id: args.id, title: 'Order name');
          break;
        default:
          throw Exception('Invalid route: ${settings.name}');
      }
      return MaterialPageRoute<void>(builder: builder, settings: settings);
    };
  }
}
