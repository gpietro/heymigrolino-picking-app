import 'package:flutter/material.dart';

class NumericStepButton extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int counter;

  final Function onChange;

  const NumericStepButton(
      {Key? key,
      this.minValue = 0,
      this.maxValue = 10,
      required this.counter,
      required this.onChange})
      : super(key: key);

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Card(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.remove,
                color: Colors.orange,
              ),
              iconSize: 26.0,
              onPressed: () {
                if (widget.counter > widget.minValue) {
                  widget.onChange(widget.counter-1);
                }                  
              },
            ),
            Text(
              '${widget.counter}',
              textAlign: TextAlign.center,
            ),
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.orange,
              ),
              iconSize: 26.0,
              onPressed: () {                
                if (widget.counter < widget.maxValue) {
                  widget.onChange(widget.counter+1);
                }                
              },
            ),
          ],
        ),
      )
    ]);
  }
}
