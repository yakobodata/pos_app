import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:uuid/uuid.dart';

import '../models/order.dart';
import '../models/order_item.dart';
import 'menu_provider.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ====================== STATE ======================
  Order? _currentOrder;
  List<Order> _orders = [];
  bool _isLoading = false;

  Order? get currentOrder => _currentOrder;
  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  // ====================== START NEW ORDER ======================
  void startNewOrder({
    required String tableNumber,
    String? userId,
    double taxRate = 0.10,
  }) {
    _currentOrder = Order(
      id: const Uuid().v4(),
      tableNumber: tableNumber,
      createdByUserId: userId,
      taxRate: taxRate,
      items: [],
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }

  // ====================== ADD ITEM ======================
  void addItemToCurrentOrder(OrderItem item, MenuProvider menuProvider) {
    if (_currentOrder == null) return;

    final existingIndex = _currentOrder!.items.indexWhere(
      (i) => i.menuItemId == item.menuItemId,
    );

    if (existingIndex >= 0) {
      // Item already exists → increase quantity
      _currentOrder!.items[existingIndex].quantity += item.quantity;
    } else {
      // New item
      _currentOrder!.items.add(item);
    }

    // Decrease stock in Firebase + local list
    menuProvider.decreaseStock(item.menuItemId, item.quantity);

    notifyListeners();
  }

  // ====================== UPDATE QUANTITY ======================
  void updateQuantity(String menuItemId, int newQuantity) {
    if (_currentOrder == null) return;

    final index = _currentOrder!.items.indexWhere(
      (i) => i.menuItemId == menuItemId,
    );

    if (index == -1) return;

    if (newQuantity <= 0) {
      _currentOrder!.items.removeAt(index);
    } else {
      _currentOrder!.items[index].quantity = newQuantity;
    }

    notifyListeners();
  }

  // ====================== REMOVE ITEM ======================
  void removeItemFromCurrentOrder(String menuItemId) {
    _currentOrder?.items.removeWhere((i) => i.menuItemId == menuItemId);
    notifyListeners();
  }

  // ====================== SET TIP ======================
  void setTip(double tip) {
    if (_currentOrder != null) {
      _currentOrder!.tipAmount = tip;
      notifyListeners();
    }
  }

  // ====================== SET TAX RATE ======================
  void setTaxRate(double rate) {
    if (_currentOrder != null) {
      _currentOrder!.taxRate = rate;
      notifyListeners();
    }
  }

  // ====================== CANCEL CURRENT ORDER ======================
  void cancelCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  // ====================== FINALIZE / PAY ORDER ======================
  Future<void> finalizeOrder() async {
    if (_currentOrder == null || _currentOrder!.items.isEmpty) return;

    final order = _currentOrder!;
    order.status = OrderStatus.paid;

    try {
      await _db.collection('orders').doc(order.id).set({
        'tableNumber': order.tableNumber,
        'status': 'paid',
        'createdBy': order.createdByUserId,
        'subtotal': order.subtotal,
        'taxRate': order.taxRate,
        'taxAmount': order.tax,
        'tipAmount': order.tipAmount,
        'totalAmount': order.total,
        'createdAt': FieldValue.serverTimestamp(),
        'paidAt': FieldValue.serverTimestamp(),
        'items': order.items
            .map((i) => {
                  'menuItemId': i.menuItemId,
                  'name': i.name,
                  'unitPrice': i.unitPrice,
                  'quantity': i.quantity,
                  'totalPrice': i.total,
                  'barcode': i.barcode,
                })
            .toList(),
      });

      // Add to local list (newest first)
      _orders.insert(0, order);
      _currentOrder = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving order: $e');
      rethrow;
    }
  }

  // ====================== LOAD ORDERS (for Reports) ======================
  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      _orders = snapshot.docs.map((doc) {
        final data = doc.data();

        final List<OrderItem> items = [];
        if (data['items'] != null) {
          for (final item in data['items']) {
            items.add(OrderItem(
              menuItemId: item['menuItemId'] ?? '',
              name: item['name'] ?? '',
              unitPrice: (item['unitPrice'] as num?)?.toDouble() ?? 0,
              quantity: item['quantity'] ?? 0,
              barcode: item['barcode'] ?? '',
            ));
          }
        }

        return Order(
          id: doc.id,
          tableNumber: data['tableNumber'] ?? '',
          items: items,
          status: _parseStatus(data['status']),
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          createdByUserId: data['createdBy'],
          taxRate: (data['taxRate'] as num?)?.toDouble() ?? 0.10,
          tipAmount: (data['tipAmount'] as num?)?.toDouble() ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ====================== REAL-TIME LISTENER (optional) ======================
  void listenToOrders() {
    _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      _orders = snapshot.docs.map((doc) {
        final data = doc.data();

        final List<OrderItem> items = [];
        if (data['items'] != null) {
          for (final item in data['items']) {
            items.add(OrderItem(
              menuItemId: item['menuItemId'] ?? '',
              name: item['name'] ?? '',
              unitPrice: (item['unitPrice'] as num?)?.toDouble() ?? 0,
              quantity: item['quantity'] ?? 0,
              barcode: item['barcode'] ?? '',
            ));
          }
        }

        return Order(
          id: doc.id,
          tableNumber: data['tableNumber'] ?? '',
          items: items,
          status: _parseStatus(data['status']),
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          createdByUserId: data['createdBy'],
          taxRate: (data['taxRate'] as num?)?.toDouble() ?? 0.10,
          tipAmount: (data['tipAmount'] as num?)?.toDouble() ?? 0,
        );
      }).toList();

      notifyListeners();
    });
  }

  // ====================== HELPER ======================
  OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'paid':
        return OrderStatus.paid;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      default:
        return OrderStatus.pending;
    }
  }
}