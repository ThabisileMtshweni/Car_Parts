
import 'package:flutter/material.dart';
import '../store.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final int partId;

  const ProductDetailsScreen({
    super.key,
    required this.partId,
  });

  @override
  Widget build(BuildContext context) {
    final shop = Shop.instance;

    return AnimatedBuilder(
      animation: shop,
      builder: (context, child) {
        final part = shop.byId(partId);

        if (part == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Product Details'),
            ),
            body: const Center(
              child: Text('Product unavailable'),
            ),
          );
        }

        final quantityInCart = shop.cart[part.id] ?? 0;

        final canAddToCart =
            part.stock > quantityInCart;

        final cartCount = shop.cart.values.fold<int>(
          0,
              (sum, quantity) => sum + quantity,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Product Details'),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: 'View Cart',
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  child: const Icon(Icons.shopping_cart),
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
            ],
          ),

          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // PRODUCT IMAGE PLACEHOLDER
                      Container(
                        height: 190,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade50,
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.car_repair,
                          size: 110,
                          color: Colors.deepOrange,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // PRODUCT NAME
                      Text(
                        part.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // CATEGORY
                      Text(
                        'Category: ${part.category}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // DESCRIPTION
                      const Text(
                        'Product Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        part.description,
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 20),

                      // VEHICLE COMPATIBILITY
                      const Text(
                        'Vehicle Compatibility',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car,
                            color: Colors.deepOrange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              part.vehicle,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // STOCK AVAILABILITY
                      Row(
                        children: [
                          Icon(
                            part.stock > 0
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: part.stock > 0
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            part.stock > 0
                                ? 'In Stock: ${part.stock}'
                                : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 16,
                              color: part.stock > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // PRICE
                      Text(
                        money(part.price),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ),

                // BOTTOM BUTTONS
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: canAddToCart
                              ? () {
                            shop.addToCart(part);

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
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
                          }
                              : null,
                          icon: const Icon(
                            Icons.add_shopping_cart,
                          ),
                          label: Text(
                            part.stock == 0
                                ? 'Out of Stock'
                                : !canAddToCart
                                ? 'Stock Limit Reached'
                                : 'Add to Cart',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                            Colors.deepOrange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const CartScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.shopping_cart,
                          ),
                          label: const Text(
                            'View Cart / Checkout',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
