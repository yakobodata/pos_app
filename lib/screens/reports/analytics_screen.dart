import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/order_provider.dart';
import '../../models/order.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.orders
        .where((o) => o.status == OrderStatus.paid)
        .toList();

    final currency = NumberFormat.currency(symbol: '\$');

    // ===== Calculations =====
    double totalRevenue = 0;
    double totalTax = 0;
    double totalTips = 0;
    int totalOrders = orders.length;
    int totalItemsSold = 0;

    final Map<String, int> itemSales = {}; // name -> quantity

    for (final order in orders) {
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

    // Top selling items
    final topItems = itemSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== SUMMARY CARDS =====
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
            childAspectRatio: 1.4,
            children: [
              _summaryCard(
                title: 'Total Revenue',
                value: currency.format(totalRevenue),
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              _summaryCard(
                title: 'Orders',
                value: totalOrders.toString(),
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

          const SizedBox(height: 28),

          // ===== TOP SELLING ITEMS =====
          Text(
            'Top Selling Items',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          if (topItems.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No sales data yet'),
              ),
            )
          else
            Card(
              child: Column(
                children: List.generate(
                  topItems.length > 5 ? 5 : topItems.length,
                  (index) {
                    final entry = topItems[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade50,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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

          const SizedBox(height: 28),

          // ===== EXTRA INFO =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow('Total Tax Collected', currency.format(totalTax)),
                  _infoRow('Average Order Value',
                      totalOrders == 0
                          ? '\$0.00'
                          : currency.format(totalRevenue / totalOrders)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
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
}