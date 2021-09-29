import 'package:demo/models/order.dart';
import 'package:demo/state/application_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'completed_order_detail.dart';
import 'completed_order_detail_arguments.dart';

class CompletedOrderList extends StatefulWidget {
  static const routeName = '/completed_order_list';

  const CompletedOrderList({Key? key}) : super(key: key);

  @override
  CompletedOrderListState createState() => CompletedOrderListState();
}

class CompletedOrderListState extends State<CompletedOrderList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Bestellliste'),
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
        ),
        body: Consumer<ApplicationState>(builder: (context, appState, _) {
          Map<String, Order> completeOrders = Map.of(appState.completeOrders)
            ..removeWhere((key, value) => value.locationId != appState.selectedLocation?.id);
          return ListView.builder(
              itemCount: completeOrders.length,
              itemBuilder: (context, index) {
                String key = completeOrders.keys.elementAt(index);
                return _itemBuilder(
                    context, completeOrders[key]!, key);
              });
        }));
  }

  void _onTapOrder(BuildContext context, String orderId) {
    Navigator.pushNamed(context, CompletedOrderDetail.routeName,
        arguments: CompletedOrderDetailArguments(orderId));
  }

  Widget _itemBuilder(BuildContext context, Order order, String docId) {
    return GestureDetector(
        onTap: () => _onTapOrder(context, docId),
        key: Key('order_list_item_${order.id}'),
        child: Card(          
          child: ListTile(
              title: Text('Bestellnummer ${order.orderNumber}'),
              subtitle: Text(
                  '${order.createdTime()} - ${order.products.length} Produkte (${order.totalPrice} ${order.currency})'))));
  }
}
