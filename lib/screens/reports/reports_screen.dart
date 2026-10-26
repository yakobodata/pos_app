import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/order_provider.dart';
import '../../models/order.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final allOrders = orderProvider.orders;
    final paidOrders = allOrders.where((o) => o.status == OrderStatus.paid).toList();
    final currency = NumberFormat.currency(symbol: '\$');

    // ===== Analytics Calculations =====
    double totalRevenue = 0;
    double totalTax = 0;
    double totalTips = 0;
    int totalItemsSold = 0;
    final Map<String, int> itemSales = {};

    for (final order in paidOrders) {
      totalRevenue += order.total;
      totalTax += order.tax;
      totalTips += order.tipAmount;

      for (final item in order.items) {
        totalItemsSold += item.quantity;
        itemSales.update(
          item.name,
          (value) => value + item.quantity,
          ifAbsent: () => item.quantity,
        );
      }
    }

    final topItems = itemSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===================== SUMMARY =====================
          Text(
            'Sales Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _summaryCard(
                title: 'Revenue',
                value: currency.format(totalRevenue),
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              _summaryCard(
                title: 'Orders',
                value: paidOrders.length.toString(),
                icon: Icons.receipt_long,
                color: Colors.blue,
              ),
              _summaryCard(
                title: 'Items Sold',
                value: totalItemsSold.toString(),
                icon: Icons.shopping_bag,
                color: Colors.orange,
              ),
              _summaryCard(
                title: 'Tips',
                value: currency.format(totalTips),
                icon: Icons.volunteer_activism,
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ===================== TOP ITEMS =====================
          Text(
            'Top Selling Items',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          Card(
            child: topItems.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No sales data yet'),
                  )
                : Column(
                    children: List.generate(
                      topItems.length > 5 ? 5 : topItems.length,
                      (index) {
                        final entry = topItems[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade50,
                            child: Text('${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          title: Text(entry.key),
                          trailing: Text(
                            '${entry.value} sold',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
                  ),
          ),

          const SizedBox(height: 24),

          // ===================== EXTRA STATS =====================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow('Total Tax Collected', currency.format(totalTax)),
                  _infoRow(
                    'Average Order Value',
                    paidOrders.isEmpty
                        ? '\$0.00'
                        : currency.format(totalRevenue / paidOrders.length),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ===================== ORDER HISTORY =====================
          Text(
            'Order History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          if (allOrders.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No orders recorded yet'),
              ),
            )
          else
            ...allOrders.reversed.map((order) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(order.status).withOpacity(0.15),
                    child: Icon(Icons.receipt, color: _statusColor(order.status)),
                  ),
                  title: Text(
                    'Table: ${order.tableNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy • HH:mm').format(order.createdAt),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currency.format(order.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        order.status.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: _statusColor(order.status),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _showOrderDetails(context, order),
                ),
              );
            }),
        ],
      ),
    );
  }

  // ===================== HELPERS =====================

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.paid:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.pending:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _showOrderDetails(BuildContext context, Order order) {
    final currency = NumberFormat.currency(symbol: '\$');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: controller,
                children: [
                  Text('Order Details',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Table: ${order.tableNumber}'),
                  Text(DateFormat('dd MMM yyyy – HH:mm').format(order.createdAt)),
                  Text('Status: ${order.status.name.toUpperCase()}'),
                  const Divider(height: 30),
                  ...order.items.map((item) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('${item.quantity}x ${item.name}'),
                      trailing: Text(currency.format(item.total)),
                    );
                  }),
                  const Divider(height: 24),
                  _infoRow('Subtotal', currency.format(order.subtotal)),
                  _infoRow('Tax', currency.format(order.tax)),
                  _infoRow('Tip', currency.format(order.tipAmount)),
                  const SizedBox(height: 6),
                  _infoRow('Total', currency.format(order.total)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}