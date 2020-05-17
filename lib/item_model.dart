class CartItemModel{
  String vendorId;
  String productId;
  int quantity;

  CartItemModel({this.vendorId, this.productId, this.quantity});
}

class VendorItemModel{
  String id;
  String name;
  int price;

  VendorItemModel({this.id, this.name, this.price});
}