import 'package:VendorApp/cart_bloc.dart';
import 'package:VendorApp/cart_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartHelper {
  CartHelper._();
  static final CartHelper instance = CartHelper._();
  List<CartItemModel> _cartItems;
  CartBloc _cartBloc = CartBloc();

  Future<void> initializeCart() async {
    if (_cartItems == null) {
      List<CartItemModel> cartItems = [];
      //TODO: Fetch cart data from firestore and assign it ro _cartItems
      Firestore.instance
          .collection('Vendors')
          .getDocuments()
          .then((QuerySnapshot qs) {
        qs.documents.forEach((snapshot) {
          cartItems.add(CartItemModel.fromMap(snapshot.documentID, snapshot.data));
        });
        _cartItems = cartItems;
        _cartBloc.setCart(cartItems.length);
      });
    } else {
      print('CART HAS ALREADY BEEN INITIALIZED.');
    }
  }

  List<CartItemModel> get cartItems {
    assert(_cartItems != null);
    return _cartItems;
  }

  Future<void> addToCart(CartItemModel item) {
    _cartBloc.addToCart();
    //TODO: Upload data to firestore and add item to _cartItem
    return Firestore.instance.collection('Vendors').add(item.toMap()).then((DocumentReference docRef) {
      print('Added to cart');
      item.id = docRef.documentID;
      _cartItems.add(item);
    }).catchError((e) {
      print("Failed to add to cart!");
      _cartBloc.removeFromCart();
    });
  }

  Future<void> removeFromCart(CartItemModel item) {
    _cartBloc.removeFromCart();
    //TODO: Delete data from firestore and remove item from _cartItem
    return Firestore.instance.collection('Vendors').document(item.id).delete().then((_) {
      print('Removed to cart');
      _cartItems.remove(item);
    }).catchError((e) {
      print("Failed to remove from cart!");
      _cartBloc.addToCart();
    });
  }
}
