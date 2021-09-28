import 'package:demo/models/order.dart';
import 'package:demo/models/order_location.dart';
import 'package:demo/screens/admin/completed_order_list.dart';
import 'package:demo/screens/order_detail/order_detail.dart';
import 'package:demo/screens/order_detail/order_detail_arguments.dart';
import 'package:demo/state/application_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderList extends StatefulWidget {
  static const routeName = '/';
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
              title: Text('Bestellnummer ${order.orderNumber}'),
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
          drawer: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: const EdgeInsets.only(top: 25.0),
              children: [
                const SizedBox(
                  height: 55.0,
                  child: DrawerHeader(
                    child: Text('Locations', style: TextStyle(fontSize: 16.0)),
                      decoration: BoxDecoration(
                      color: Colors.orange
                    ),                    
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.only(left: 20.0)
                  ),
                ),
                ...appState.orderLocations.map((OrderLocation orderLocation) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        appState.selectedLocation = orderLocation;
                      });
                      Navigator.of(context).pop();
                    },
                    key: Key('location_${orderLocation.id}'),
                    child: Card(
                      child: ListTile(
                        title: Text('${orderLocation.zip} ${orderLocation.name}'),
                      )
                    )
                  );                  
                })
              ],
            ),
          ),
          appBar: AppBar(
            title: Text('Bestellliste ${appState.selectedLocation?.name}'),
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
