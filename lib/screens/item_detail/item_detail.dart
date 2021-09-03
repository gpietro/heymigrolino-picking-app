import 'package:flutter/material.dart';

class ItemDetail extends StatefulWidget {
  const ItemDetail(
      {Key? key,
      required this.id,
      required this.name,
      required this.price,
      required this.quantity})
      : super(key: key);

  final int id;
  final String name;
  final double price;
  final int quantity;

  static const routeName = '/item_detail';

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.id}: ${widget.name}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text(widget.name)],
        ),
      )
    );
  }
}
