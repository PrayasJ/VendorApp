import 'package:rxdart/rxdart.dart';

class CartBloc {
  int items = 0;
  BehaviorSubject<int> _cartDetector;

  static CartBloc _cartBloc;

  factory CartBloc() {
    if (_cartBloc == null) _cartBloc = CartBloc._();
    return _cartBloc;
  }

  CartBloc._() {
    _cartDetector = BehaviorSubject<int>();
  }

  Stream<int> get cartStream => _cartDetector.stream;

  void addToCart() {
    if(items < 99) items += 1;
    _cartDetector.add(items);
  }

  void removeFromCart() {
    if(items > 0) items -= 1;
    _cartDetector.add(items);
  }

  void setCart(int items){
    this.items = items;
    _cartDetector.add(this.items);
  }

  void dispose() {
    if (!_cartDetector.isClosed) {
      _cartDetector.close();
      _cartBloc = null;
    }
  }
}
