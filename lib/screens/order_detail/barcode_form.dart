import 'package:demo/state/application_state.dart';
import 'package:flutter/material.dart';

// Define a custom Form widget.
class BarcodeForm extends StatefulWidget {
  const BarcodeForm({Key? key, required this.onSubmit}) : super(key: key);

  final Function onSubmit;

  @override
  BarcodeFormState createState() {
    return BarcodeFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class BarcodeFormState extends State<BarcodeForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<BarcodeFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String barcode = '';
    ScanResult? scanResult;
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
              child: TextFormField(
                onSaved: (value) {
                  barcode = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter barcode';
                  }
                  if (value.length != 8 && value.length != 13) {
                    return 'The barcode must have 8 or 13 digits';
                  }
                  if (double.tryParse(value) == null) {
                    return 'The barcode needs to be a number';
                  }
                  if (scanResult == ScanResult.error) {
                    return 'Product not found!';
                  } 
                  return null;
                },
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () async {
                  _formKey.currentState!.save();
                  scanResult = await widget.onSubmit(barcode);
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Product scanned!'),
                      backgroundColor: Colors.green));
                  }
                },
                child: const Text('OK'),                
              )
            ],
          )
        ],
      ),
    );
  }
}