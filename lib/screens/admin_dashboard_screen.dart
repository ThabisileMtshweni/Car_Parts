
import 'package:flutter/material.dart';
import '../store.dart';
import 'product_form_screen.dart';
import 'orders_screen.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  // Confirm before deleting a product
  Future<void> confirmDelete(
      BuildContext context,
      Part part,
      ) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Delete ${part.name}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (yes == true) {
      Shop.instance.deletePart(part.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = Shop.instance;

    return AnimatedBuilder(
      animation: shop,
      builder: (context, child) {
        final lowStockCount = shop.parts
            .where((part) => part.stock < 5)
            .length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Seller Dashboard'),
            actions: [
              IconButton(
                tooltip: 'Orders',
                icon: const Icon(Icons.receipt_long),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const OrdersScreen(admin: true),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
                onPressed: () {
                  shop.logout();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                        (route) => false,
                  );
                },
              ),
            ],
          ),

          floatingActionButton:
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const ProductFormScreen(),
                ),
              );
            },
            label: const Text('Add Part'),
            icon: const Icon(Icons.add),
          ),

          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      'Products: ${shop.parts.length}',
                    ),
                    Text(
                      'Low stock (<5): $lowStockCount',
                    ),
                    Text(
                      'Orders: ${shop.orders.length}',
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: shop.parts.length,
                  itemBuilder: (context, index) {
                    final Part part =
                    shop.parts[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(part.name),
                        subtitle: Text(
                          '${money(part.price)} '
                              '• Stock ${part.stock}',
                        ),

                        // FIXED: Row instead of Wrap
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductFormScreen(
                                          partId: part.id,
                                        ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                confirmDelete(
                                  context,
                                  part,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
