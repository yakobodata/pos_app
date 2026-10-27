import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  String _selectedPaymentMethod = 'Cash';
  final _tipController = TextEditingController(text: '0');
  final List<String> _paymentMethods = ['Cash', 'Card', 'Mobile Money', 'Other'];

  @override
  void dispose() {
    _tipController.dispose();
    super.dispose();
  }

  void _updateTip(Order order) {
    final tip = double.tryParse(_tipController.text) ?? 0.0;
    context.read<OrderProvider>().setTip(tip);
  }

  Future<void> _completePayment(Order order) async {
    final orderProvider = context.read<OrderProvider>();
    final auth = context.read<AuthProvider>();

    // Finalize the order
    orderProvider.finalizeOrder();

    // Show success message
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text('Total Paid: \$${order.total.toStringAsFixed(2)}'),
            Text('Method: $_selectedPaymentMethod'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // go back to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final order = orderProvider.currentOrder;

    if (order == null || order.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bill')),
        body: const Center(child: Text('No active order to bill')),
      );
    }

    final currency = NumberFormat.currency(symbol: '\UGX ', decimalDigits: 2 );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Bill'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ========== ORDER INFO ==========
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Table / Customer: ${order.tableNumber}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Order ID: ${order.id.substring(0, 8)}...'),
                Text('Date: ${DateFormat('dd MMM yyyy – HH:mm').format(order.createdAt)}'),
              ],
            ),
          ),

          // ========== ITEMS LIST ==========
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.quantity} × ${currency.format(item.unitPrice)}'),
                    trailing: Text(
                      currency.format(item.total),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),

          // ========== TOTALS + PAYMENT ==========
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Subtotal
                _buildRow('Subtotal', currency.format(order.subtotal)),
                // _buildRow('Tax (${(order.taxRate * 0).toStringAsFixed(0)}%)',
                //     currency.format(order.tax)),

                // Tip input
                // Row(
                //   children: [
                //     const Text('Tip', style: TextStyle(fontSize: 16)),
                //     const Spacer(),
                //     SizedBox(
                //       width: 100,
                //       child: TextField(
                //         controller: _tipController,
                //         keyboardType: TextInputType.number,
                //         textAlign: TextAlign.right,
                //         decoration: const InputDecoration(
                //           isDense: true,
                //           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                //           border: OutlineInputBorder(),
                //           prefixText: '\$ ',
                //         ),
                //         onChanged: (_) => _updateTip(order),
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 8),
                const Divider(),

                // Total
                _buildRow(
                  'TOTAL',
                  currency.format(order.total),
                  isTotal: true,
                ),
                const SizedBox(height: 16),

                // Payment Method
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Payment Method',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _paymentMethods.map((method) {
                    final isSelected = _selectedPaymentMethod == method;
                    return ChoiceChip(
                      label: Text(method),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedPaymentMethod = method);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: Text(
                      'Pay ${currency.format(order.total)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _completePayment(order),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}