import 'package:demo/models/order.dart';
import 'package:demo/screens/admin/completed_order_list.dart';
import 'package:demo/screens/order_detail/order_detail.dart';
import 'package:demo/screens/order_detail/order_detail_arguments.dart';
import 'package:demo/state/application_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderList extends StatefulWidget {
  static const routeName = '/order_list';
  static const menuAdmin = 'Einstellungen';

  const OrderList({Key? key}) : super(key: key);

  @override
  OrderListState createState() => OrderListState();
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
              title: Text('Bestellnummer ${order.orderNumber} - ${order.customerName ?? '...'}'),
              subtitle: Text(
                  '${order.createdTime()} - ${order.products.length} Produkte (${order.totalPrice} ${order.currency})'))));
}

onSelected(BuildContext context, String item) {
  switch (item) {
    case OrderList.menuAdmin:
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const CompletedOrderList()));
      break;
    default:
      break;
  }
}

class OrderListState extends State<OrderList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      Map<String, Order> orders = Map.of(appState.orders)
        ..removeWhere(
            (key, value) => value.locationId != appState.selectedLocation?.id);

      return Scaffold(
          appBar: AppBar(
            title: Text(appState.selectedLocation?.name ?? "Loading..."),
            actions: [
              PopupMenuButton(
                  onSelected: (String item) => onSelected(context, item),
                  itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                            value: OrderList.menuAdmin,
                            child: Text('Einstellungen'))
                      ])
            ],
          ),
          body: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                String key = orders.keys.elementAt(index);
                return _itemBuilder(context, orders[key]!, key);
              }));
    });
  }
}
