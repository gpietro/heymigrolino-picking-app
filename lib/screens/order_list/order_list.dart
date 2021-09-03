import 'package:demo/models/order.dart';
import 'package:demo/screens/order_detail/order_detail.dart';
import 'package:demo/screens/order_detail/order_detail_arguments.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderList extends StatelessWidget {
  const OrderList({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final orders = Order.fetchAll();

    return Scaffold(
        appBar: AppBar(title: const Text('Bestellung auswählen')),
        body: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _itemBuilder(context, orders[index]);
            }));
  }

  void _onTapOrder(BuildContext context, int orderId) {
    Navigator.pushNamed(context, OrderDetail.routeName,
        arguments: OrderDetailArguments(orderId));
  }

  Widget _itemBuilder(BuildContext context, Order order) {
    final DateFormat formatter = DateFormat('HH:mm');
    return GestureDetector(
        onTap: () => _onTapOrder(context, order.id),
        key: Key('order_list_item_${order.id}'),
        child: Card(
          child: ListTile(
            title: Text('Bestellnummer ${order.id}'),
            subtitle: Text(
                '${formatter.format(order.dateTime)} Uhr - ${order.items.fold<int>(0, (acc, curr) => acc + curr.quantity)} Produkte (60 CHF)'),
          ),
        ));
  }
}
