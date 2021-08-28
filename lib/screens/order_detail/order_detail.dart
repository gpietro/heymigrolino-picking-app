import 'package:demo/models/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({Key? key, required this.id, required this.title}) : super(key: key);

  final int id;
  final String title;
  static const routeName = '/order_detail';

  @override
  State<OrderDetail> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<OrderDetail> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = Order.fetchById(widget.id);

    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.title} #${widget.id}'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>
            [...order!.items.map((item) => Text(item.name))],
          ),
        ),
        floatingActionButton: SpeedDial(
            icon: Icons.add,
            activeIcon: Icons.close,
            spacing: 3,
            children: [
              SpeedDialChild(
                  child: const Icon(Icons.add),
                  onTap: _incrementCounter,
                  label: 'Increment'),
              SpeedDialChild(
                  child: const Icon(Icons.remove),
                  onTap: _decrementCounter,
                  label: 'Decrement')
            ])
        /*
      FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.    
      */
        );
  }
}
