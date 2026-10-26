import 'order_item.dart';
import 'package:uuid/uuid.dart';

//we have an enum of Order Statuses
enum OrderStatus { pending, preparing, ready, paid, cancelled }

// here we have a class called Order which accepts and variable which doesnot change called id
// tableNumber
// which accepts a list called items of type OrderItem
class Order {
  final String id;
  String tableNumber;          // or customer name
  List<OrderItem> items;
  OrderStatus status;
  DateTime createdAt;
  String? createdByUserId;
  double taxRate;              // e.g. 0.10 = 10%
  double tipAmount;

  //constructor for the class Order
  //which also has an initializer list that says if no id was given , create a unique id
  // it no items were given , then create new items
  // if no date was givem , then give current date
  Order({
    // the string is allowed to be null
    String? id,
    required this.tableNumber,
    List<OrderItem>? items,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
    this.createdByUserId,
    this.taxRate = 0.10,
    this.tipAmount = 0.0,
  })  : id = id ?? const Uuid().v4(),
        items = items ?? [],
        createdAt = createdAt ?? DateTime.now();

  // and it also has the following variables
  double get subtotal => items.fold(0.0, (sum, i) => sum + i.total);
  double get tax => subtotal * taxRate;
  double get total => subtotal + tax + tipAmount;
}