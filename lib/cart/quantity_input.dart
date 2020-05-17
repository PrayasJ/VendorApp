import 'package:flutter/material.dart';

class QuantityInput extends StatefulWidget {
  final TextEditingController controller;

  const QuantityInput({Key key, this.controller}) : super(key: key);

  @override
  _QuantityInputState createState() => _QuantityInputState();
}

class _QuantityInputState extends State<QuantityInput> {
  int n = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.keyboard_arrow_up),
            onPressed: () {
              setState(() {
                n += 1;
                widget.controller.text = n.toString();
              });
            },
          ),
          Expanded(child: Center(child: Text(n.toString()))),
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down),
            onPressed: () {
              if (n > 1) {
                setState(() {
                  n -= 1;
                  widget.controller.text = n.toString();
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
