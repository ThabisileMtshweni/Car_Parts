
import 'package:flutter/material.dart';
import '../store.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'login_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() =>
      _CustomerHomeScreenState();
}

class _CustomerHomeScreenState
    extends State<CustomerHomeScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final shop = Shop.instance;

    return AnimatedBuilder(
      animation: shop,
      builder: (context, child) {
        // Filter products by name, category or vehicle.
        final shown = shop.parts.where((part) {
          final productText =
          '${part.name} ${part.category} ${part.vehicle}'
              .toLowerCase();

          return productText.contains(
            search.toLowerCase().trim(),
          );
        }).toList();

        // Count the products in the shopping cart.
        final cartCount = shop.cart.values.fold<int>(
          0,
              (total, quantity) => total + quantity,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('AutoParts Connect'),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            actions: [
              // MY ORDERS
              IconButton(
                tooltip: 'My Orders',
                icon: const Icon(Icons.receipt_long),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const OrdersScreen(admin: false),
                    ),
                  );
                },
              ),

              // SHOPPING CART
              IconButton(
                tooltip: 'Shopping Cart',
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  child: const Icon(
                    Icons.shopping_cart,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(),
                    ),
                  );
                },
              ),

              // LOGOUT
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

          body: Column(
            children: [
              // WELCOME MESSAGE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                color: Colors.deepOrange.shade50,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to AutoParts Connect!',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Find the right spare parts for your vehicle.',
                    ),
                  ],
                ),
              ),

              // SEARCH FIELD
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText:
                    'Search part, category or vehicle',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      search = value;
                    });
                  },
                ),
              ),

              // PRODUCT COUNT
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Available Parts (${shown.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // PRODUCT LIST
              Expanded(
                child: shown.isEmpty
                    ? const Center(
                  child: Text(
                    'No matching spare parts found',
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: shown.length,
                  itemBuilder: (context, index) {
                    final part = shown[index];

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          12,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // PRODUCT NAME
                            Row(
                              children: [
                                const Icon(
                                  Icons.car_repair,
                                  size: 35,
                                  color:
                                  Colors.deepOrange,
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        part.name,
                                        style:
                                        const TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        part.category,
                                        style:
                                        const TextStyle(
                                          color:
                                          Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Vehicle: ${part.vehicle}',
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Price: ${money(part.price)}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              part.stock > 0
                                  ? 'In Stock: ${part.stock}'
                                  : 'Out of Stock',
                              style: TextStyle(
                                color: part.stock > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // PRODUCT BUTTONS
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ProductDetailsScreen(
                                                partId:
                                                part.id,
                                              ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'View Details',
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 8,
                                ),

                                Expanded(
                                  child: FilledButton(
                                    onPressed:
                                    part.stock <= 0 ||
                                        (shop.cart[
                                        part.id] ??
                                            0) >=
                                            part.stock
                                        ? null
                                        : () {
                                      shop.addToCart(
                                        part,
                                      );

                                      ScaffoldMessenger
                                          .of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${part.name} added to cart',
                                          ),
                                          duration:
                                          const Duration(
                                            seconds: 2,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Add to Cart',
                                    ),
                                  ),
                                ),
                              ],
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
