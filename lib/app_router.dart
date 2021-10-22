import 'package:demo/screens/bags_selection/bags_selection.dart';
import 'package:demo/screens/bags_selection/bags_selection_arguments.dart';
import 'package:demo/screens/completed_order_detail/completed_order_detail.dart';
import 'package:demo/screens/completed_order_detail/completed_order_detail_arguments.dart';

import 'package:demo/screens/order_detail/order_detail_arguments.dart';
import 'package:flutter/material.dart';
import 'screens/location_list/location_list.dart';
import 'screens/order_list/order_list.dart';
import 'screens/order_detail/order_detail.dart';
import 'state/application_state.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Picking App',
        onGenerateRoute: _routes(),
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        navigatorObservers: <NavigatorObserver>[ApplicationState.observer],
        home: const LocationList());
  }

  RouteFactory _routes() {
    return (settings) {
      WidgetBuilder builder;
      switch (settings.name) {
        case OrderList.routeName:
          ApplicationState.analytics.logEvent(name: "route_tracking", parameters: {"route": "order-list"});
          builder = (BuildContext context) => const OrderList();
          break;
        case LocationList.routeName:
          ApplicationState.analytics.logEvent(name: "route_tracking", parameters: {"route": "location-list"});
          builder = (BuildContext context) => const LocationList();
          break;
        case OrderDetail.routeName:
          final args = settings.arguments as OrderDetailArguments;
          ApplicationState.analytics.logEvent(name: "route_tracking", parameters: {"route": "order-detail", "orderId": args.id});          
          builder = (BuildContext context) => OrderDetail(id: args.id);
          break;
        case CompletedOrderDetail.routeName:
          final args = settings.arguments as CompletedOrderDetailArguments;
          ApplicationState.analytics.logEvent(name: "route_tracking", parameters: {"route": "completed-order-detail", "orderId": args.id});          
          builder = (BuildContext context) => CompletedOrderDetail(id: args.id);
          break;
        case BagsSelection.routeName:
          final args = settings.arguments as BagsSelectionArguments;
          ApplicationState.analytics.logEvent(name: "route_tracking", parameters: {"route": "bags-selection", "orderId": args.id});          
          builder = (BuildContext context) =>
              BagsSelection(id: args.id, locationId: args.locationId);
          break;
        default:
          throw Exception('Invalid route: ${settings.name}');
      }
      return MaterialPageRoute<void>(builder: builder, settings: settings);
    };
  }
}
