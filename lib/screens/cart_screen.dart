
import 'package:flutter/material.dart';
import '../store.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = Shop.instance;

    return AnimatedBuilder(
      animation: shop,
      builder: (context, child) {
        final cartItems = shop.cart.entries.toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Shopping Cart'),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),

          body: Column(
            children: [
              // SHOPPING CART ITEMS
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(
                  child: Text(
                    'Your shopping cart is empty',
                    style: TextStyle(fontSize: 18),
                  ),
                )
                    : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final entry = cartItems[index];
                    final part = shop.byId(entry.key);

                    if (part == null) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(
                          Icons.car_repair,
                          size: 40,
                          color: Colors.deepOrange,
                        ),
                        title: Text(
                          part.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price: ${money(part.price)}',
                            ),
                            Text(
                              'Quantity: ${entry.value}',
                            ),
                            Text(
                              'Subtotal: ${money(part.price * entry.value)}',
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                shop.changeQty(
                                  part.id,
                                  -1,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                shop.changeQty(
                                  part.id,
                                  1,
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

              // CART TOTAL AND CHECKOUT BUTTON
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total: ${money(shop.cartTotal)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // CHECKOUT BUTTON
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: cartItems.isEmpty
                              ? null
                              : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const CheckoutScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.payment,
                          ),
                          label: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
