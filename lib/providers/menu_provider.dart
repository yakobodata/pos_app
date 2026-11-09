
// import 'package:flutter/foundation.dart';
// import '../models/menu_item.dart';
// import 'package:uuid/uuid.dart';

// class MenuProvider with ChangeNotifier {

//   // this is a list called _items with type called MenuItem
//   final List<MenuItem> _items = [
//     MenuItem(id: '1', name: 'Burger', price: 8.50, barcode: '1234567890123', category: 'Main', stockQuantity: 50),
//     MenuItem(id: '2', name: 'Fries', price: 3.50, barcode: '1234567890124', category: 'Side', stockQuantity: 100),
//     MenuItem(id: '3', name: 'Coke', price: 2.00, barcode: '1234567890125', category: 'Drink', stockQuantity: 80),
//   ];

//   //This code makes the list _items immute , i dnot know why
//   List<MenuItem> get items => List.unmodifiable(_items);

//   // this returns an Item of type MenuItem but you must give it a Barcode
//   MenuItem? findByBarcode(String barcode) {
//     try {
//       //it will return the first item where the barcode is equal to the barcode given and is also available
//       // or else return nothing
//       return _items.firstWhere((i) => i.barcode == barcode && i.isAvailable);
//     } catch (_) {
//       return null;
//     }
//   }


//   //this code helps us add item to the menu but since we already made the list immute , i dnot know how this is going to work?
//   void addItem(MenuItem item) {
//     _items.add(item);
//     notifyListeners();
//   }

//   // this function helps us update a specific item
//   void updateItem(MenuItem item) {
//     final idx = _items.indexWhere((i) => i.id == item.id);
//     if (idx != -1) {
//       _items[idx] = item;
//       notifyListeners();
//     }
//   }

//   // this function is used to delete a specific item
//   void removeItem(String id) {
//     _items.removeWhere((i) => i.id == id);
//     notifyListeners();
//   }

//   // this function is used to decrease the Quantity using the stockQuantity paramter
//   void decreaseStock(String menuItemId, int qty) {
//     final item = _items.firstWhere((i) => i.id == menuItemId);
//     item.stockQuantity = (item.stockQuantity - qty).clamp(0, 999999);
//     if (item.stockQuantity == 0) item.isAvailable = false;
//     notifyListeners();
//   }

//   // this function is used to increase the stock of a specific menu item
//   void increaseStock(String menuItemId, int qty) {
//     final item = _items.firstWhere((i) => i.id == menuItemId);
//     item.stockQuantity += qty;
//     item.isAvailable = true;
//     notifyListeners();
//   }

//   // this function is used to set the stock a specific menu item
//   void setStock(String menuItemId, int newStock) {
//     final item = _items.firstWhere((i) => i.id == menuItemId);
//     item.stockQuantity = newStock.clamp(0, 999999);
//     item.isAvailable = item.stockQuantity > 0;
//     notifyListeners();
//   }
// }


// This is the new code that uses Firebase Firestore to manage menu items in real-time
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';

// This provider manages menu items in real-time using Firebase Firestore
class MenuProvider with ChangeNotifier {
  //
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // This is a list of menu items that will be fetched from Firestore
  List<MenuItem> _items = [];
  // This is a boolean that indicates whether the 
  //provider is currently loading data from Firestore
  bool _isLoading = false;

  // This getter returns an unmodifiable view of the menu items list
  List<MenuItem> get items => List.unmodifiable(_items);
  //this getter returns the _isLoading boolean to indicate 
  //whether the provider is currently loading data from Firestore 
  bool get isLoading => _isLoading;

  // This method loads menu items from Firestore and updates the _items list
  Future<void> loadItems() async {
    // Set loading to true and notify listeners
    _isLoading = true;
    // Notify listeners that the loading state has changed
    notifyListeners();

    // Fetch menu items from Firestore, ordered by name
    //A snapshot is a point-in-time copy of data. In Firestore,
    //a snapshot contains the data returned by a query or the 
    //current data from a live listener.
    final snapshot = await _db.collection('menu_items').orderBy('name').get();

    // Map the snapshot documents to MenuItem objects and update the _items list
    _items = snapshot.docs.map((doc) {
      // Get the data from the document snapshot
      final data = doc.data();
      // Create a MenuItem object from the document data
      return MenuItem(
        id: doc.id,
        name: data['name'] ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0,
        barcode: data['barcode'] ?? '',
        category: data['category'] ?? 'General',
        stockQuantity: data['stockQuantity'] ?? 0,
        isAvailable: data['isAvailable'] ?? true,
      );
    }).toList();
    // Set loading to false and notify listeners that the data has been loaded
    _isLoading = false;
    notifyListeners();
  }

  // Real-time listener (great for manager)
  void listenToItems() {
    // Listen to changes in the menu_items collection in Firestore
    _db.collection('menu_items').orderBy('name').snapshots().listen((snapshot) {
      _items = snapshot.docs.map((doc) {
        final data = doc.data();
        return MenuItem(
          id: doc.id,
          name: data['name'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0,
          barcode: data['barcode'] ?? '',
          category: data['category'] ?? 'General',
          stockQuantity: data['stockQuantity'] ?? 0,
          isAvailable: data['isAvailable'] ?? true,
        );
      }).toList();
      notifyListeners();
    });
  }

  // This method finds a menu item by its barcode 
  //and returns it, or null if not found
  MenuItem? findByBarcode(String barcode) {
    // Try to find the first item in the _items list that matches the given barcode
    try {
      return _items.firstWhere((i) => i.barcode == barcode);
    } catch (_) {
      // If no item is found, return null
      return null;
    }
  }

  // This method adds a new menu item to Firestore and reloads the items list
  Future<void> addItem(MenuItem item) async {
    //
    await _db.collection('menu_items').doc(item.id).set({
      'name': item.name,
      'price': item.price,
      'barcode': item.barcode,
      'category': item.category,
      'stockQuantity': item.stockQuantity,
      'isAvailable': item.isAvailable,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Reload the items list after adding a new item
    await loadItems();
  }

  // This method updates an existing menu item in Firestore and reloads the items list
  Future<void> setStock(String id, int newStock) async {
    // Update the stock quantity and availability of a menu item in Firestore
    await _db.collection('menu_items').doc(id).update({
      'stockQuantity': newStock,
      'isAvailable': newStock > 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // This method updates an existing menu item in Firestore and reloads the items list
  Future<void> increaseStock(String id, int qty) async {
    // Get a reference to the menu item document in Firestore
    final ref = _db.collection('menu_items').doc(id);
    // Use a transaction to safely increase the stock quantity and update availability
    await _db.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final current = snap.data()?['stockQuantity'] ?? 0;
      txn.update(ref, {
        'stockQuantity': current + qty,
        'isAvailable': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // This method decreases the stock quantity of a menu item in Firestore and updates its availability
  Future<void> decreaseStock(String id, int qty) async {
    final ref = _db.collection('menu_items').doc(id);
    await _db.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final current = snap.data()?['stockQuantity'] ?? 0;
      final newStock = (current - qty).clamp(0, 999999);
      txn.update(ref, {
        'stockQuantity': newStock,
        'isAvailable': newStock > 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}