
import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import 'package:uuid/uuid.dart';

class MenuProvider with ChangeNotifier {

  // this is a list called _items with type called MenuItem
  final List<MenuItem> _items = [
    MenuItem(id: '1', name: 'Burger', price: 8.50, barcode: '1234567890123', category: 'Main', stockQuantity: 50),
    MenuItem(id: '2', name: 'Fries', price: 3.50, barcode: '1234567890124', category: 'Side', stockQuantity: 100),
    MenuItem(id: '3', name: 'Coke', price: 2.00, barcode: '1234567890125', category: 'Drink', stockQuantity: 80),
  ];

  //This code makes the list _items immute , i dnot know why
  List<MenuItem> get items => List.unmodifiable(_items);

  // this returns an Item of type MenuItem but you must give it a Barcode
  MenuItem? findByBarcode(String barcode) {
    try {
      //it will return the first item where the barcode is equal to the barcode given and is also available
      // or else return nothing
      return _items.firstWhere((i) => i.barcode == barcode && i.isAvailable);
    } catch (_) {
      return null;
    }
  }


  //this code helps us add item to the menu but since we already made the list immute , i dnot know how this is going to work?
  void addItem(MenuItem item) {
    _items.add(item);
    notifyListeners();
  }

  // this function helps us update a specific item
  void updateItem(MenuItem item) {
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      _items[idx] = item;
      notifyListeners();
    }
  }

  // this function is used to delete a specific item
  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  // this function is used to decrease the Quantity using the stockQuantity paramter
  void decreaseStock(String menuItemId, int qty) {
    final item = _items.firstWhere((i) => i.id == menuItemId);
    item.stockQuantity = (item.stockQuantity - qty).clamp(0, 999999);
    if (item.stockQuantity == 0) item.isAvailable = false;
    notifyListeners();
  }

  // this function is used to increase the stock of a specific menu item
  void increaseStock(String menuItemId, int qty) {
    final item = _items.firstWhere((i) => i.id == menuItemId);
    item.stockQuantity += qty;
    item.isAvailable = true;
    notifyListeners();
  }

  // this function is used to set the stock a specific menu item
  void setStock(String menuItemId, int newStock) {
    final item = _items.firstWhere((i) => i.id == menuItemId);
    item.stockQuantity = newStock.clamp(0, 999999);
    item.isAvailable = item.stockQuantity > 0;
    notifyListeners();
  }
}

