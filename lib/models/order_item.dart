// here we have a class called OrderItem
// the class has paramters 

class OrderItem {
  final String menuItemId;
  final String name;
  final double unitPrice;
  int quantity;
  final String barcode;

  //we also have constructors
  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.barcode,
  });

  //we also have a variable called total
  double get total => unitPrice * quantity;
}