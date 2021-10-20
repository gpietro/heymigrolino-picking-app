import 'dart:async';

import 'package:demo/models/order.dart';
import 'package:demo/screens/order_list/order_list.dart';
import 'package:demo/state/application_state.dart';
import 'package:demo/widgets/numeric_step_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BagsSelection extends StatefulWidget {
  static const routeName = '/bags_selection';

  const BagsSelection({Key? key, required this.id, required this.locationId})
      : super(key: key);

  final String id;
  final int locationId;

  @override
  BagsSelectionState createState() => BagsSelectionState();
}

class BagsSelectionState extends State<BagsSelection> {
  int counterBags = 1;
  int counterFBags = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Taschen"),
        ),
        backgroundColor: Colors.white,
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wie viele Papiertaschen hast du gepackt?', style: TextStyle(fontSize: 16)),
                NumericStepButton(
                    onChange: (value) {
                      setState(() => {counterBags = value});
                    },
                    counter: counterBags),
                const Divider(
                  height: 20,
                  thickness: 1,
                ),
                const Text('Wie viele Tiefkühltaschen hast du gepackt?', style: TextStyle(fontSize: 16)),
                NumericStepButton(
                    onChange: (value) {
                      setState(() => {counterFBags = value});
                    },
                    counter: counterFBags),
                const Divider(
                  height: 20,
                  thickness: 1,
                ),
                const Text(
                    'Nachdem die Produkte gepackt wurden, bitte das Handy an der Kasse abgeben!', style: TextStyle(fontSize: 16))
              ],
            )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Timer timer = Timer(const Duration(milliseconds: 3000), () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  OrderList.routeName, (Route<dynamic> route) => false);
            });
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => AlertDialog(
                content:
                    Column(mainAxisSize: MainAxisSize.min, children: const [
                  Text('Alles ist gepackt', style: TextStyle(fontSize: 20)),
                  Icon(
                    Icons.check_outlined,
                    color: Colors.green,
                    size: 48.0,
                  ),
                  Text('Gut gemacht!')
                ]),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          OrderList.routeName, (Route<dynamic> route) => false);
                    },
                  ),
                ],
              ),
            ).then((value) {
              timer.cancel();
            });
            appState.updateOrderStatus(widget.id, OrderStatus.complete);
            var order = appState.orders[widget.id];
            appState.updateOrderBags(widget.id, order!.orderNumber,
                order.locationId, counterBags, counterFBags);
          },
          child: const Icon(Icons.done),
          backgroundColor: Colors.orange,
        ),
      );
    });
  }
}
