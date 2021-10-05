import 'package:demo/screens/order_list/order_list.dart';
import 'package:demo/state/application_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationList extends StatefulWidget {
  static const routeName = '/location_list';

  const LocationList({Key? key}) : super(key: key);

  @override
  LocationListState createState() => LocationListState();
}

class LocationListState extends State<LocationList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Wählen Sie den Standort aus"),
        ),
        body: ListView.builder(
          itemCount: appState.orderLocations.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  appState.selectedLocation = appState.orderLocations[index];
                });
                Navigator.of(context).pushNamedAndRemoveUntil(
                          OrderList.routeName, (Route<dynamic> route) => false);                
              },
              key: Key('location_${appState.orderLocations[index].id}'),
              child: Card(
                child: ListTile(
                  title: Text('${appState.orderLocations[index].zip} ${appState.orderLocations[index].name}'),
                )
              )
            );
          }
        )
      );
    });
  }
}
