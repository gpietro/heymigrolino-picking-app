import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/models/order.dart';
import 'package:demo/screens/order_detail/order_detail.dart';
import 'package:demo/screens/order_detail/order_detail_arguments.dart';
import 'package:flutter/material.dart';

class OrderList extends StatefulWidget {
  static const routeName = '/';

  const OrderList({Key? key}) : super(key: key);

  @override
  OrderListState createState() => OrderListState();
}

final ordersRef = FirebaseFirestore.instance.collection('orders').withConverter<Order>(
    fromFirestore: (snapshots, _) => Order.fromJson(snapshots.data()!),
    toFirestore: (order, _) => order.toJson(),
  );

class OrderListState extends State<OrderList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bestellung auswählen')),
      body: StreamBuilder<QuerySnapshot<Order>>(
        stream: ordersRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData;

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              final docId = data.docs[index].reference.id;
              final order = data.docs[index].data();              
              return _itemBuilder(context, order, docId);
            }
          );
        },
      ),
    );
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
              '10:00 Uhr - ${order.products.length} Produkte (${order.totalPrice} ${order.currency})')
          )
        )
    );
  }
}