import 'package:VendorApp/cart/cart_bloc.dart';
import 'package:VendorApp/cart/item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartHelper {
  CartHelper._();
  static final CartHelper instance = CartHelper._();
  List<CartItemModel> _cartItems;
  CartBloc _cartBloc = CartBloc();
  String _uid;

  Future<bool> initializeCart(String uid) async {
    _uid = uid;
    if (_cartItems == null) {
      List<CartItemModel> cartItems = [];
      return Firestore.instance
          .collection('Cart')
          .document(uid)
          .get()
          .then((DocumentSnapshot ds) {
        ds.data?.forEach((key, value) {
          List<String> ids = key.split('###');
          cartItems.add(CartItemModel(vendorId: ids[0], productId: ids[1], quantity: value));
        });
        _cartItems = cartItems;
        _cartBloc.setCart(cartItems.length);
        return true;
      });
    } else {
      print('CART HAS ALREADY BEEN INITIALIZED.');
      return true;
    }
  }
  

  List<CartItemModel> get cartItems {
    assert(_cartItems != null);
    return _cartItems;
  }

  bool isInitialised(){
    return !(_cartItems == null);
  }

  Future<void> addToCart(CartItemModel item) {
    assert(_cartItems != null);
    _cartBloc.addToCart();
    return Firestore.instance
        .collection('Cart')
        .document(_uid)
        .setData({'${item.vendorId}###${item.productId}': item.quantity}, merge: true).then((_) async {
      print('Added to cart');
      _cartItems = null;
      await initializeCart(_uid);
    }).catchError((e) {
      print("Failed to add to cart!");
      _cartBloc.removeFromCart();
    });
  }

  Future<void> removeFromCart(CartItemModel item) {
    assert(_cartItems != null);
    _cartBloc.removeFromCart();
    return Firestore.instance
        .collection('Cart')
        .document(_uid)
        .updateData({'${item.vendorId}###${item.productId}': FieldValue.delete()}).then((_) async {
      print('Removed to cart');
      _cartItems = null;
      await initializeCart(_uid);
    }).catchError((e) {
      print("Failed to remove from cart!");
      _cartBloc.addToCart();
    });
  }
}
