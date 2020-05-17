import 'package:VendorApp/cart/cart_helper.dart';
import 'package:VendorApp/cart/item_model.dart';
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
  int _selectedIndex=0;


  @override
  void initState() {
    _error = false;
    loadItems();
    super.initState();
  }

  Future<void> loadItems() async {
    List<VendorItemModel> items = [];
    List<int> quantities = [];
    Future.forEach(CartHelper.instance.cartItems,
        (CartItemModel cartItem) async {
      DocumentReference docRef =
          Firestore.instance.collection('Vendors').document(cartItem.vendorId);
      DocumentSnapshot ds = await docRef.get();
      VendorItemModel vItem = VendorItemModel(
        vendorId: ds.documentID,
        productId: cartItem.productId,
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
            trailing: IconButton(
              icon: Icon(Icons.remove_shopping_cart),
              color: Colors.red,
              onPressed: () async {
                CartItemModel _cartItem = CartItemModel(
                    vendorId: _items[i].vendorId,
                    productId: _items[i].productId,
                    quantity: _quantities[i]);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                );
                try {
                  await CartHelper.instance.removeFromCart(_cartItem);
                } catch (e) {
                  print('Failed to remove');
                }
                Navigator.of(context).pop();
                setState(() {
                  _items.removeAt(i);
                  _quantities.removeAt(i);
                });
              },
            ),
          );
        },
      );
    else
      return Center(child: Text('Cart is Empty'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 60,
            child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.blueGrey[300],
                      child: FlatButton(
                        padding: EdgeInsets.all(10.0),
                        onPressed: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Center(child: Text('VIEW DETAILED BILL',style: TextStyle(fontSize: 20,color: Colors.white),))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(color: Colors.black, width: 2,),
                  Expanded(
                    child: Container(
                      color: Colors.green,
                      child: FlatButton(
                        padding: EdgeInsets.all(0.0),
                        onPressed: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text('PROCEED TO PAY',style: TextStyle(fontSize: 20,color: Colors.white),)
                          ],
                        ),
                      ),
                    ),
                  )
                ]
            ),
          )
      ),
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
