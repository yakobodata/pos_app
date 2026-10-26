 
import 'package:flutter/material.dart';
import 'package:pos_app/screens/reports/analytics_screen.dart';
import 'package:pos_app/screens/reports/reports_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'order/new_order_screen.dart';
// Uncomment these as you create the screens:
// import 'order/order_list_screen.dart';
// import 'billing/bill_screen.dart';
import 'inventory/inventory_screen.dart';
// import 'menu/menu_management_screen.dart';
// import 'users/user_management_screen.dart';
// import 'reports/reports_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //Give me the AuthProvider and keep this screen updated when it changes.
    final auth = context.watch<AuthProvider>();

    final user = auth.currentUser;

    if (user == null) {
      // Safety check – should never happen if navigation is correct
      return const LoginScreen();
    }

    final isManager = auth.isManager;

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Dashboard'),
        centerTitle: true,
        actions: [
          // User info chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  user.username[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              label: Text(
                '${user.username} (${user.role.name})',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user.username}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                isManager
                    ? 'You have full access to all features'
                    : 'Cashier access – orders & billing only',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Grid of feature cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    // Always available for both roles
                    _FeatureCard(
                      title: 'New Order',
                      icon: Icons.add_shopping_cart,
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NewOrderScreen(),
                          ),
                        );
                      },
                    ),
                    _FeatureCard(
                      title: 'Active Orders',
                      icon: Icons.receipt_long,
                      color: Colors.blue,
                      onTap: () {
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order List screen coming soon')),
                        );
                      },
                    ),
                    _FeatureCard(
                      title: 'Billing',
                      icon: Icons.payment,
                      color: Colors.green,
                      onTap: () {
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => const BillScreen()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Billing screen coming soon')),
                        );
                      },
                    ),

                    // Manager-only features
                    if (isManager) ...[
                      _FeatureCard(
                        title: 'Inventory',
                        icon: Icons.inventory_2,
                        color: Colors.orange,
                        onTap: () {
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(content: Text('Inventory screen coming soon')),
                          // );
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const InventoryScreen()),
                            (route) => false,
                            );
                        },
                      ),
                      _FeatureCard(
                        title: 'Menu Management',
                        icon: Icons.restaurant_menu,
                        color: Colors.purple,
                        onTap: () {
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuManagementScreen()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Menu Management coming soon')),
                          );
                        },
                      ),
                      _FeatureCard(
                        title: 'User Management',
                        icon: Icons.people,
                        color: Colors.indigo,
                        onTap: () {
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User Management coming soon')),
                          );
                        },
                      ),
                      _FeatureCard(
                        title: 'Reports',
                        icon: Icons.analytics,
                        color: Colors.redAccent,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reports screen coming soon')),
                          );
                        },
                      ),
                      _FeatureCard(
                        title: 'Analytics',
                        icon: Icons.analytics,
                        color: Colors.redAccent,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reports screen coming soon')),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable feature card widget
class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}