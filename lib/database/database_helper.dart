import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos_app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    // ====================== USERS ======================
    await db.execute('''
      CREATE TABLE users (
        id            TEXT PRIMARY KEY,
        username      TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        role          TEXT NOT NULL,
        full_name     TEXT,
        is_active     INTEGER DEFAULT 1,
        created_at    TEXT NOT NULL
      )
    ''');

    // ====================== CATEGORIES ======================
    await db.execute('''
      CREATE TABLE categories (
        id          TEXT PRIMARY KEY,
        name        TEXT NOT NULL UNIQUE,
        description TEXT
      )
    ''');

    // ====================== MENU ITEMS ======================
    await db.execute('''
      CREATE TABLE menu_items (
        id              TEXT PRIMARY KEY,
        name            TEXT NOT NULL,
        description     TEXT,
        price           REAL NOT NULL,
        barcode         TEXT UNIQUE,
        category_id     TEXT,
        stock_quantity  INTEGER DEFAULT 0,
        low_stock_alert INTEGER DEFAULT 5,
        is_available    INTEGER DEFAULT 1,
        image_url       TEXT,
        created_at      TEXT NOT NULL,
        updated_at      TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // ====================== ORDERS ======================
    await db.execute('''
      CREATE TABLE orders (
        id                TEXT PRIMARY KEY,
        order_number      TEXT UNIQUE,
        status            TEXT NOT NULL,
        created_by        TEXT,
        subtotal          REAL DEFAULT 0,
        tax_rate          REAL DEFAULT 0.10,
        tax_amount        REAL DEFAULT 0,
        tip_amount        REAL DEFAULT 0,
        total_amount      REAL DEFAULT 0,
        notes             TEXT,
        created_at        TEXT NOT NULL,
        updated_at        TEXT,
        paid_at           TEXT,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');

    // ====================== ORDER ITEMS ======================
    await db.execute('''
      CREATE TABLE order_items (
        id              TEXT PRIMARY KEY,
        order_id        TEXT NOT NULL,
        menu_item_id    TEXT NOT NULL,
        item_name       TEXT NOT NULL,
        unit_price      REAL NOT NULL,
        quantity        INTEGER NOT NULL,
        total_price     REAL NOT NULL,
        notes           TEXT,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
        FOREIGN KEY (menu_item_id) REFERENCES menu_items (id)
      )
    ''');

    // ====================== PAYMENTS ======================
    await db.execute('''
      CREATE TABLE payments (
        id              TEXT PRIMARY KEY,
        order_id        TEXT NOT NULL,
        amount          REAL NOT NULL,
        payment_method  TEXT NOT NULL,
        transaction_ref TEXT,
        paid_by         TEXT,
        paid_at         TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (paid_by) REFERENCES users (id)
      )
    ''');

    // ====================== INVENTORY LOGS ======================
    await db.execute('''
      CREATE TABLE inventory_logs (
        id              TEXT PRIMARY KEY,
        menu_item_id    TEXT NOT NULL,
        change_type     TEXT NOT NULL,
        quantity_change INTEGER NOT NULL,
        previous_stock  INTEGER,
        new_stock       INTEGER,
        reason          TEXT,
        performed_by    TEXT,
        created_at      TEXT NOT NULL,
        FOREIGN KEY (menu_item_id) REFERENCES menu_items (id),
        FOREIGN KEY (performed_by) REFERENCES users (id)
      )
    ''');

    // Useful indexes
    await db.execute('CREATE INDEX idx_menu_barcode ON menu_items(barcode)');
    await db.execute('CREATE INDEX idx_order_status ON orders(status)');
    await db.execute('CREATE INDEX idx_order_created ON orders(created_at)');
    await db.execute('CREATE INDEX idx_order_items_order ON order_items(order_id)');

    // Insert demo users
    await _insertDemoData(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add migration logic here later when you change version
  }

  // ====================== DEMO DATA ======================
  Future _insertDemoData(Database db) async {
    final now = DateTime.now().toIso8601String();
    const uuid = Uuid();

    // Demo users
    await db.insert('users', {
      'id': 'user-cashier',
      'username': 'cashier',
      'password_hash': '1234', // later change to hashed password
      'role': 'cashier',
      'full_name': 'Demo Cashier',
      'is_active': 1,
      'created_at': now,
    });

    await db.insert('users', {
      'id': 'user-manager',
      'username': 'manager',
      'password_hash': 'admin',
      'role': 'manager',
      'full_name': 'Demo Manager',
      'is_active': 1,
      'created_at': now,
    });

    // Demo category
    final catId = uuid.v4();
    await db.insert('categories', {
      'id': catId,
      'name': 'General',
      'description': 'Default category',
    });

    // Demo menu items
    final items = [
      {
        'id': uuid.v4(),
        'name': 'Burger',
        'price': 8.50,
        'barcode': '1234567890123',
        'stock_quantity': 50,
      },
      {
        'id': uuid.v4(),
        'name': 'Fries',
        'price': 3.50,
        'barcode': '1234567890124',
        'stock_quantity': 100,
      },
      {
        'id': uuid.v4(),
        'name': 'Coke',
        'price': 2.00,
        'barcode': '1234567890125',
        'stock_quantity': 80,
      },
    ];

    for (final item in items) {
      await db.insert('menu_items', {
        ...item,
        'category_id': catId,
        'low_stock_alert': 5,
        'is_available': 1,
        'created_at': now,
      });
    }
  }

  // =====================================================
  // HELPER METHODS YOU WILL USE A LOT
  // =====================================================

  // ---------- MENU ITEMS ----------
  Future<List<Map<String, dynamic>>> getAllMenuItems() async {
    final db = await database;
    return await db.query('menu_items', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getMenuItemByBarcode(String barcode) async {
    final db = await database;
    final result = await db.query(
      'menu_items',
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateStock(String menuItemId, int newStock) async {
    final db = await database;
    return await db.update(
      'menu_items',
      {
        'stock_quantity': newStock,
        'is_available': newStock > 0 ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [menuItemId],
    );
  }

  Future<void> increaseStock(String menuItemId, int qty, {String? userId}) async {
    final db = await database;
    final item = await db.query('menu_items', where: 'id = ?', whereArgs: [menuItemId]);
    if (item.isEmpty) return;

    final current = item.first['stock_quantity'] as int;
    final newStock = current + qty;

    await updateStock(menuItemId, newStock);

    // Log the change
    await db.insert('inventory_logs', {
      'id': const Uuid().v4(),
      'menu_item_id': menuItemId,
      'change_type': 'add',
      'quantity_change': qty,
      'previous_stock': current,
      'new_stock': newStock,
      'reason': 'Manual stock addition',
      'performed_by': userId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ---------- ORDERS ----------
  Future<String> createOrder({
    required String tableNumber,
    required String createdBy,
    double taxRate = 0.10,
  }) async {
    final db = await database;
    final id = const Uuid().v4();
    final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    await db.insert('orders', {
      'id': id,
      'order_number': orderNumber,
      'table_number': tableNumber,
      'status': 'pending',
      'created_by': createdBy,
      'tax_rate': taxRate,
      'created_at': DateTime.now().toIso8601String(),
    });

    return id;
  }

  Future<void> addOrderItem({
    required String orderId,
    required String menuItemId,
    required String itemName,
    required double unitPrice,
    required int quantity,
  }) async {
    final db = await database;

    await db.insert('order_items', {
      'id': const Uuid().v4(),
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'item_name': itemName,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': unitPrice * quantity,
    });

    // Decrease stock
    final item = await db.query('menu_items', where: 'id = ?', whereArgs: [menuItemId]);
    if (item.isNotEmpty) {
      final current = item.first['stock_quantity'] as int;
      await updateStock(menuItemId, (current - quantity).clamp(0, 999999));
    }
  }

  // ---------- USERS ----------
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password_hash = ? AND is_active = 1',
      whereArgs: [username, password],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Close database (optional)
  Future close() async {
    final db = await database;
    db.close();
  }
}