class CartItemModel{
  String vendorId;
  String productId;
  int quantity;

  CartItemModel({this.vendorId, this.productId, this.quantity});
}

class VendorItemModel{
  String vendorId;
  String productId;
  String name;
  int price;

  VendorItemModel({this.vendorId, this.productId, this.name, this.price});
}