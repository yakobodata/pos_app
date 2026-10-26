import 'package:flutter/material.dart';
import 'package:pos_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../providers/menu_provider.dart';
import '../../models/menu_item.dart';
import '../../widgets/barcode_scanner_widget.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  //okay we have private variables here
  final _searchController = TextEditingController();
  String _searchQuery = '';

  //we do this to free the memory
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //we have a private function which returns list called MenuItem
  // although it takes in a items from a list 
  List<MenuItem> _filteredItems(List<MenuItem> items) {
    if (_searchQuery.isEmpty) return items;
    //we store the results of the search query into a small letters in a variable called query
    final query = _searchQuery.toLowerCase();
    return items.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.barcode.contains(_searchQuery) ||
          item.category.toLowerCase().contains(query);
    }).toList();
  }

  // ========== ADD STOCK BY BARCODE ==========
  void _showAddStockByBarcode(String barcode) {
    //we have a menuProvider which is reading the context and we are finding the item by barcode

    final menuProvider = context.read<MenuProvider>();
    //we are finding the item by barcode and storing it in a variable called item
    final item = menuProvider.findByBarcode(barcode);

    if (item == null) {
      // Item not found
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Item not found'),
          content: Text('No product with barcode "$barcode" exists.\nCreate a new one?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                print('Creating new item with barcode: $barcode');
                Future.microtask(() => _showCreateNewItemDialog(barcode));
                // _showCreateNewItemDialog(barcode);
              },
              child: const Text('Create New'),
            ),
          ],
        ),
      );
      return;
    }

    // Item found → add stock
    final qtyController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Stock – ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current stock: ${item.stockQuantity}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity to add',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(qtyController.text) ?? 0;
              if (qty > 0) {
                menuProvider.increaseStock(item.id, qty);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('+$qty added to ${item.name}')),
                );
              }
            },
            child: const Text('Add Stock'),
          ),
        ],
      ),
    );
  }

  // ========== CREATE NEW ITEM ==========
  void _showCreateNewItemDialog(String barcode) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController(text: 'General');
    final stockController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Initial Stock',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Text('Barcode: $barcode',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0.0;
              final stock = int.tryParse(stockController.text) ?? 0;

              if (name.isEmpty) return;

              final newItem = MenuItem(
                id: const Uuid().v4(),
                name: name,
                price: price,
                barcode: barcode,
                category: categoryController.text.trim(),
                stockQuantity: stock,
                isAvailable: stock > 0,
              );

              context.read<MenuProvider>().addItem(newItem);
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${newItem.name} created')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // ========== EDIT STOCK ==========
  void _showEditStockDialog(MenuItem item) {
    final stockController =
        TextEditingController(text: item.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Stock – ${item.name}'),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Stock Quantity',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text) ?? 0;
              context.read<MenuProvider>().setStock(item.id, newStock);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Stock updated for ${item.name}')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final items = _filteredItems(menuProvider.items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        // Explicitly add the back button here
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()), // Replace with your Home Screen widget class name
            (route) => false, // Clears the back stack so pressing back won't return to the inventory
          ); // Pops back to the previous screen
          }
        ),
        actions: [
          // ===== SCANNER BUTTON =====
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan barcode',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BarcodeScannerWidget(
                    onBarcodeDetected: (barcode) {
                      _showAddStockByBarcode(barcode);
                    },
                  ),
                ),
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => BarcodeScannerWidget(
              //       onBarcodeDetected: (barcode) {
              //         _showAddStockByBarcode(barcode);
              //       },
              //     ),
              //   ),
              // );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search name, barcode or category...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // List
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No items found'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isLow = item.stockQuantity <= 5;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                isLow ? Colors.red.shade100 : Colors.green.shade100,
                            child: Icon(
                              isLow ? Icons.warning : Icons.inventory_2,
                              color: isLow ? Colors.red : Colors.green,
                            ),
                          ),
                          title: Text(item.name,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Barcode: ${item.barcode}'),
                              Text('Category: ${item.category}'),
                              Text(
                                'Stock: ${item.stockQuantity}',
                                style: TextStyle(
                                  color: isLow ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditStockDialog(item),
                          ),
                          onTap: () => _showEditStockDialog(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateNewItemDialog(
              'MANUAL-${DateTime.now().millisecondsSinceEpoch}');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}