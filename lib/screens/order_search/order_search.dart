import 'package:demo/screens/barcode_scanner/barcode_scanner.dart';
import 'package:flutter/material.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({Key? key, required this.id, required this.title})
      : super(key: key);

  final int id;
  final String title;
  static const routeName = '/order_detail';

  @override
  State<OrderDetail> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<OrderDetail> {
  void _barcodeScanner() {
    Navigator.pushNamed(context, BarcodeScanner.routeName);
  }

  @override
  Widget build(BuildContext context) {
    // final order = Order.fetchById(widget.id);
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.title} #${widget.id}'),
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tight(const Size(300, 50)),
                  child: TextFormField(
                    initialValue: '',
                    decoration: const InputDecoration(                
                      labelText: 'Bestellnummer',              
                    ),
                    validator: (value) => value != '10' ? 'Bestellung nicht gefunden' : null,
                  )
                )
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                  }
                },
                child: const Text('Bestätigung'),
              ),
            ]
                // <Widget>[...order!.items.map((item) => Text(item.name))],
                ),
          ),
        ),
        /*body: ListView.builder(
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              return _itemBuilder(context, orders[index]);
            }),*/
        floatingActionButton: FloatingActionButton(
            onPressed: _barcodeScanner,
            tooltip: 'Barcode Scan',
            child: const Icon(Icons
                .qr_code_scanner)) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
