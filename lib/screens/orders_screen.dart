
import 'package:flutter/material.dart';
import '../store.dart';

class OrdersScreen extends StatelessWidget {
  final bool admin;

  const OrdersScreen({
    super.key,
    required this.admin,
  });

  static const List<String> statuses = [
    'Pending',
    'Confirmed',
    'Ready for collection',
    'Completed',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final shop = Shop.instance;

    return AnimatedBuilder(
      animation: shop,
      builder: (context, child) {
        // Admin sees all orders.
        // Customer sees only their own orders.
        final orders = shop.orders
            .where(
              (order) =>
          admin || order.customer == shop.email,
        )
            .toList()
            .reversed
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              admin ? 'Manage Orders' : 'My Orders',
            ),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),

          body: orders.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 75,
                  color: Colors.grey,
                ),
                const SizedBox(height: 15),
                Text(
                  admin
                      ? 'No customer orders yet'
                      : 'You have not placed any orders',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 14,
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // ORDER NUMBER AND TOTAL
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Order #${order.id}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            money(order.total),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ORDER DATE
                      Text(
                        'Date: '
                            '${order.created.day}/'
                            '${order.created.month}/'
                            '${order.created.year}',
                      ),

                      const Divider(),

                      // CUSTOMER DETAILS
                      if (admin) ...[
                        Text(
                          'Customer: ${order.customer}',
                        ),
                        Text(
                          'Phone: ${order.phone}',
                        ),
                        const SizedBox(height: 10),
                      ],

                      // ORDERED PRODUCTS
                      const Text(
                        'Ordered Parts',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      ...order.lines.map(
                            (line) => Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 6,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${line.quantity} × '
                                      '${line.name}',
                                ),
                              ),
                              Text(
                                money(
                                  line.price *
                                      line.quantity,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // COLLECTION NOTES
                      if (order.notes.isNotEmpty) ...[
                        const Divider(),
                        Text(
                          'Collection Notes: '
                              '${order.notes}',
                        ),
                      ],

                      const Divider(),

                      // ADMIN STATUS MANAGEMENT
                      if (admin) ...[
                        const Text(
                          'Update Order Status',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: order.status,
                          isExpanded: true,
                          decoration:
                          const InputDecoration(
                            border:
                            OutlineInputBorder(),
                          ),
                          items: statuses.map((status) {
                            return DropdownMenuItem<
                                String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              shop.updateStatus(
                                order,
                                newStatus,
                              );
                            }
                          },
                        ),
                      ] else ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Status: ${order.status}',
                                style: const TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
