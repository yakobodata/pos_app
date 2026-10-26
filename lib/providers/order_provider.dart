import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import 'menu_provider.dart';

class OrderProvider with ChangeNotifier {
  //we have a list of orders of type Order
  final List<Order> _orders = [];

  // we also finally have an object called _currentOrder from Class order
  Order? _currentOrder;

  // we make the items in the list orders immute
  List<Order> get orders => List.unmodifiable(_orders);

  //we also have a variable called currentOrder
  Order? get currentOrder => _currentOrder;

  // we have a function that returns nothing but wants a table number and user identification to create current order
  void startNewOrder({required String tableNumber, String? userId}) {
    _currentOrder = Order(tableNumber: tableNumber, createdByUserId: userId);
    notifyListeners();
  }

  // now we also have a function that wants an item and a menu provider
  void addItemToCurrentOrder(OrderItem item, MenuProvider menuProvider) {
    //if the current order private variable has nothing return nothing , its alright
    if (_currentOrder == null) return;

    // create a variable that doesnot change called existing
    // we are sure its not null , get the 
    final existing = _currentOrder!.items.indexWhere((i) => i.menuItemId == item.menuItemId);
    if (existing >= 0) {
      _currentOrder!.items[existing].quantity += item.quantity;
    } else {
      _currentOrder!.items.add(item);
    }

    // Auto deduct inventory
    menuProvider.decreaseStock(item.menuItemId, item.quantity);
    notifyListeners();
  }

  void removeItemFromCurrentOrder(String menuItemId) {
    _currentOrder?.items.removeWhere((i) => i.menuItemId == menuItemId);
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int newQty) {
    final item = _currentOrder?.items.firstWhere((i) => i.menuItemId == menuItemId);
    if (item != null) {
      item.quantity = newQty;
      notifyListeners();
    }
  }

  void setTip(double tip) {
    _currentOrder?.tipAmount = tip;
    notifyListeners();
  }

  void setTaxRate(double rate) {
    _currentOrder?.taxRate = rate;
    notifyListeners();
  }

  void finalizeOrder() {
    if (_currentOrder != null && _currentOrder!.items.isNotEmpty) {
      _currentOrder!.status = OrderStatus.paid;
      _orders.add(_currentOrder!);
      _currentOrder = null;
      notifyListeners();
    }
  }

  void cancelCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }
}