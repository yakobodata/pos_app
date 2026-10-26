// import 'package:flutter/material.dart';
// import 'package:pos_app/widgets/barcode_scanner_widget.dart';
// import 'package:provider/provider.dart';
// import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

// import '../../providers/menu_provider.dart';
// import '../../providers/order_provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../models/order_item.dart';
// import '../../models/menu_item.dart';

// class NewOrderScreen extends StatefulWidget {
//   const NewOrderScreen({super.key});

//   @override
//   State<NewOrderScreen> createState() => _NewOrderScreenState();
// }

// class _NewOrderScreenState extends State<NewOrderScreen> {
  
//   // this is a variable
//   final _tableController = TextEditingController(text: '1');

//   @override
//   void dispose() {
//     _tableController.dispose();
//     super.dispose();
//   }

//   // ====================== SCAN BARCODE ======================
//   Future<void> _scanBarcode() async {
//     // the scancode function returns the scanned barcode
//     final String? barcode = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => BarcodeScannerWidget(
//                     onBarcodeDetected: (barcode) {
//                       final item = menuProvider.findByBarcode(barcode);
//                     }),
//     );
//     // if the barcode is null or not there , then we return it 
//     if (barcode == null || barcode == '-1') return;

//     // we watch out for the changes in Menu Provider
//     final menuProvider = context.read<MenuProvider>();

//     // we watch out for the changes in Order Provider
//     final orderProvider = context.read<OrderProvider>();

//     //we use the findByBarcode function to find the item in the menu provider using the barcode
//     final item = menuProvider.findByBarcode(barcode);
    
//     // if the item is null , then we show a snackbar that says product not found
//     if (item == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Product not found: $barcode')),
//       );
//       return;
//     }

//     //if the item is not available or the stock quantity is less than or equal to 0 ,
//     // then we show a snackbar that says this item is out of stock
//     if (!item.isAvailable || item.stockQuantity <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('This item is out of stock')),
//       );
//       return;
//     }

//     // Make sure an order is started
//     if (orderProvider.currentOrder == null) {
//       final userId = context.read<AuthProvider>().currentUser?.id;
//       orderProvider.startNewOrder(
//         tableNumber: _tableController.text.trim(),
//         userId: userId,
//       );
//     }

//     orderProvider.addItemToCurrentOrder(
//       OrderItem(
//         menuItemId: item.id,
//         name: item.name,
//         unitPrice: item.price,
//         quantity: 1,
//         barcode: item.barcode,
//       ),
//       menuProvider,
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Added ${item.name}')),
//     );
//   }

//   // ====================== ADD ITEM MANUALLY ======================
//   void _addItemManually(MenuItem item) {
//     final orderProvider = context.read<OrderProvider>();
//     final menuProvider = context.read<MenuProvider>();

//     if (orderProvider.currentOrder == null) {
//       final userId = context.read<AuthProvider>().currentUser?.id;
//       orderProvider.startNewOrder(
//         tableNumber: _tableController.text.trim(),
//         userId: userId,
//       );
//     }

//     if (!item.isAvailable || item.stockQuantity <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Out of stock')),
//       );
//       return;
//     }

//     orderProvider.addItemToCurrentOrder(
//       OrderItem(
//         menuItemId: item.id,
//         name: item.name,
//         unitPrice: item.price,
//         quantity: 1,
//         barcode: item.barcode,
//       ),
//       menuProvider,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final menuProvider = context.watch<MenuProvider>();
//     final orderProvider = context.watch<OrderProvider>();
//     final current = orderProvider.currentOrder;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('New Order'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.qr_code_scanner),
//             tooltip: 'Scan barcode',
//             onPressed: _scanBarcode,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // ===== Table / Customer =====
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               controller: _tableController,
//               decoration: const InputDecoration(
//                 labelText: 'Table / Customer',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.table_restaurant),
//               ),
//               onChanged: (value) {
//                 if (current != null) {
//                   current.tableNumber = value;
//                 }
//               },
//             ),
//           ),

//           // ===== Start Order Button =====
//           if (current == null)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.play_arrow),
//                   label: const Text('Start New Order'),
//                   onPressed: () {
//                     final userId = context.read<AuthProvider>().currentUser?.id;
//                     orderProvider.startNewOrder(
//                       tableNumber: _tableController.text.trim(),
//                       userId: userId,
//                     );
//                   },
//                 ),
//               ),
//             ),

//           // ===== Current Order Items =====
//           if (current != null) ...[
//             Expanded(
//               child: current.items.isEmpty
//                   ? const Center(child: Text('No items yet.\nScan or tap a product.'))
//                   : ListView.builder(
//                       itemCount: current.items.length,
//                       itemBuilder: (context, index) {
//                         final item = current.items[index];
//                         return Card(
//                           margin: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 4),
//                           child: ListTile(
//                             title: Text(item.name),
//                             subtitle: Text(
//                                 '\$${item.unitPrice.toStringAsFixed(2)} each'),
//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.remove_circle_outline),
//                                   onPressed: () {
//                                     if (item.quantity > 1) {
//                                       orderProvider.updateQuantity(
//                                           item.menuItemId, item.quantity - 1);
//                                     } else {
//                                       orderProvider.removeItemFromCurrentOrder(
//                                           item.menuItemId);
//                                     }
//                                   },
//                                 ),
//                                 Text('${item.quantity}',
//                                     style: const TextStyle(fontSize: 16)),
//                                 IconButton(
//                                   icon: const Icon(Icons.add_circle_outline),
//                                   onPressed: () {
//                                     orderProvider.updateQuantity(
//                                         item.menuItemId, item.quantity + 1);
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ),

//             // ===== Quick Add Menu =====
//             SizedBox(
//               height: 110,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 itemCount: menuProvider.items.length,
//                 itemBuilder: (context, index) {
//                   final m = menuProvider.items[index];
//                   return Padding(
//                     padding: const EdgeInsets.all(6),
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             m.isAvailable ? null : Colors.grey.shade300,
//                       ),
//                       onPressed: m.isAvailable ? () => _addItemManually(m) : null,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(m.name, style: const TextStyle(fontSize: 13)),
//                           Text('\$${m.price.toStringAsFixed(2)}',
//                               style: const TextStyle(fontWeight: FontWeight.bold)),
//                           Text('Stock: ${m.stockQuantity}',
//                               style: const TextStyle(fontSize: 11)),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // ===== Totals + Actions =====
//             Card(
//               margin: const EdgeInsets.all(12),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text('Subtotal'),
//                         Text('\$${current.subtotal.toStringAsFixed(2)}'),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text('Tax'),
//                         Text('\$${current.tax.toStringAsFixed(2)}'),
//                       ],
//                     ),
//                     const Divider(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text('Total',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 18)),
//                         Text(
//                           '\$${current.total.toStringAsFixed(2)}',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 18),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             icon: const Icon(Icons.payment),
//                             label: const Text('Generate Bill'),
//                             onPressed: current.items.isEmpty
//                                 ? null
//                                 : () {
//                                     // TODO: Navigate to BillScreen later
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                           content: Text('Go to Billing screen')),
//                                     );
//                                   },
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         OutlinedButton(
//                           onPressed: () {
//                             orderProvider.cancelCurrentOrder();
//                           },
//                           child: const Text('Cancel'),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_item.dart';
import '../../widgets/barcode_scanner_widget.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _tableController = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final current = orderProvider.currentOrder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Order'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan barcode',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BarcodeScannerWidget(
                    onBarcodeDetected: (barcode) {
                      final item = menuProvider.findByBarcode(barcode);
                      if (item != null) {
                        orderProvider.addItemToCurrentOrder(
                          OrderItem(
                            menuItemId: item.id,
                            name: item.name,
                            unitPrice: item.price,
                            quantity: 1,
                            barcode: item.barcode,
                          ),
                          menuProvider,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added ${item.name}')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item not found or out of stock')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _tableController,
              decoration: const InputDecoration(
                labelText: 'Table / Customer',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                if (current != null) current.tableNumber = v;
              },
            ),
          ),
          if (current == null)
            ElevatedButton(
              onPressed: () {
                orderProvider.startNewOrder(tableNumber: _tableController.text);
              },
              child: const Text('Start Order'),
            )
          else ...[
            Expanded(
              child: ListView.builder(
                itemCount: current.items.length,
                itemBuilder: (ctx, i) {
                  final item = current.items[i];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('\$${item.unitPrice.toStringAsFixed(2)} × ${item.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (item.quantity > 1) {
                              orderProvider.updateQuantity(item.menuItemId, item.quantity - 1);
                            } else {
                              orderProvider.removeItemFromCurrentOrder(item.menuItemId);
                            }
                          },
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            orderProvider.updateQuantity(item.menuItemId, item.quantity + 1);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Quick add from menu
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: menuProvider.items.length,
                itemBuilder: (ctx, i) {
                  final m = menuProvider.items[i];
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: m.isAvailable
                          ? () {
                              orderProvider.addItemToCurrentOrder(
                                OrderItem(
                                  menuItemId: m.id,
                                  name: m.name,
                                  unitPrice: m.price,
                                  quantity: 1,
                                  barcode: m.barcode,
                                ),
                                menuProvider,
                              );
                            }
                          : null,
                      child: Text('${m.name}\n\$${m.price}'),
                    ),
                  );
                },
              ),
            ),
            // Totals & actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Subtotal: \$${current.subtotal.toStringAsFixed(2)}'),
                    Text('Tax: \$${current.tax.toStringAsFixed(2)}'),
                    Text('Tip: \$${current.tipAmount.toStringAsFixed(2)}'),
                    Text('Total: \$${current.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to BillScreen for payment method selection
                              Navigator.pushNamed(context, '/bill');
                            },
                            child: const Text('Generate Bill'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => orderProvider.cancelCurrentOrder(),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}