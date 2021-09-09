import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/models/order.dart';
import 'package:demo/screens/order_detail/order_detail.dart';
import 'package:demo/screens/order_detail/order_detail_arguments.dart';
import 'package:demo/state/application_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderList extends StatefulWidget {
  static const routeName = '/';

  const OrderList({Key? key}) : super(key: key);

  @override
  OrderListState createState() => OrderListState();
}

final ordersRef =
    FirebaseFirestore.instance.collection('orders').withConverter<Order>(
          fromFirestore: (snapshots, _) => Order.fromJson(snapshots.data()!),
          toFirestore: (order, _) => order.toJson(),
        );

class OrderListState extends State<OrderList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Bestellung auswählen')),
        body: Consumer<ApplicationState>(builder: (context, appState, _) {
          return ListView.builder(
              itemCount: appState.orders.length,
              itemBuilder: (context, index) {
                String key = appState.orders.keys.elementAt(index);
                return _itemBuilder(context, appState.orders[key]!, key);
              });
        }));
  }

  void _onTapOrder(BuildContext context, String orderId) {
    Navigator.pushNamed(context, OrderDetail.routeName,
        arguments: OrderDetailArguments(orderId));
  }

  Widget _itemBuilder(BuildContext context, Order order, String docId) {
    return GestureDetector(
        onTap: () => _onTapOrder(context, docId),
        key: Key('order_list_item_${order.id}'),
        child: Card(
            child: ListTile(
                title: Text('Bestellnummer ${order.orderNumber}'),
                subtitle: Text(
                    '10:00 Uhr - ${order.products.length} Produkte (${order.totalPrice} ${order.currency})'))));
  }
}
