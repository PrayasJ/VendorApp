import 'package:VendorApp/cart_helper.dart';
import 'package:VendorApp/item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartDisplay extends StatefulWidget {
  final String uid;

  const CartDisplay({Key key, @required this.uid}) : super(key: key);
  @override
  _CartDisplayState createState() => _CartDisplayState();
}

class _CartDisplayState extends State<CartDisplay> {
  List<VendorItemModel> _items;
  List<int> _quantities;
  bool _error = false;

  @override
  void initState() {
    List<VendorItemModel> items = [];
    List<int> quantities = [];
    _error = false;
    Future.forEach(CartHelper.instance.cartItems,
        (CartItemModel cartItem) async {
      DocumentReference docRef =
          Firestore.instance.collection('Vendors').document(cartItem.vendorId);
      DocumentSnapshot ds = await docRef.get();
      VendorItemModel vItem = VendorItemModel(
        id: ds.documentID,
        name: ds.data[cartItem.productId]['name'],
        price: ds.data[cartItem.productId]['cost'],
      );
      items.add(vItem);
      quantities.add(cartItem.quantity);
    }).whenComplete(() {
      _items = items;
      _quantities = quantities;
      setState(() {});
    }).catchError((e) {
      _error = true;
      setState(() {});
    });
    super.initState();
  }

  Widget getMainBody() {
    if (_items.length > 0)
      return ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, i) {
          int p = _items[i].price;
          int q = _quantities[i];
          return ListTile(
            title: Text(_items[i].name ?? ''),
            subtitle: Text("Price : $p\nQuantity : $q"),
            isThreeLine: true,
            trailing: Text("Rs.${p * q}"),
          );
        },
      );
    else
      return Center(child: Text('Cart is Empty'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Colors.red,
      ),
      body: _error
          ? Center(
              child: Text('Something Went Wrong!'),
            )
          : _items == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : getMainBody(),
    );
  }
}
