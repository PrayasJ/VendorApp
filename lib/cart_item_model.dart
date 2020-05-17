class CartItemModel{
  String id;
  String product;
  int quantity;
  double cost;

  CartItemModel.fromMap(String id, Map<String, dynamic> m){
    this.id = id;
    product = m['Product']??'Unknown';
    quantity = m['quantity']??0;
    cost = m['Product_cost']??0;
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> m = {
      'Product':this.product,
      'Product_cost':this.cost,
      'quantity': this.quantity,
    };
    return m;
  }
}