import 'package:flutter/material.dart';
import 'package:VendorApp/cart_bloc.dart';

class CartIcon extends StatefulWidget {
  @override
  _CartIconState createState() => _CartIconState();
}

class _CartIconState extends State<CartIcon> {
  CartBloc _cartBloc;

  @override
  void initState() {
    _cartBloc = CartBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Icon(Icons.shopping_cart),
        StreamBuilder<int>(
            stream: _cartBloc.cartStream,
            initialData: 0,
            builder: (context, snapshot) {
              return Positioned(
                top: 0,
                right: 0,
                child: snapshot.data > 0
                    ? Container(
                        height: 15,
                        width: 15,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.red, width: 1),
                        ),
                        child: Text(
                          "${snapshot.data}",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      )
                    : Container(),
              );
            }),
      ],
    );
  }
}
