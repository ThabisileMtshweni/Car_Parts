
import 'package:flutter/material.dart';
import '../store.dart';
import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final form = GlobalKey<FormState>();

  final phone = TextEditingController();
  final notes = TextEditingController();

  bool isSubmitting = false;

  @override
  void dispose() {
    phone.dispose();
    notes.dispose();
    super.dispose();
  }

  void placeOrder() {
    if (isSubmitting) return;

    if (!form.currentState!.validate()) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final error = Shop.instance.checkout(
      phone.text.trim(),
      notes.text.trim(),
    );

    if (error != null) {
      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    // Show confirmation on the destination screen.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const OrdersScreen(admin: false),
      ),
          (route) => route.isFirst,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Order placed successfully for collection',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Collection order – no online payment',
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact phone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null ||
                        value.trim().length < 9) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: notes,
                  decoration: const InputDecoration(
                    labelText:
                    'Collection notes (optional)',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 20),

                AnimatedBuilder(
                  animation: Shop.instance,
                  builder: (context, child) {
                    return Text(
                      'Total: ${money(Shop.instance.cartTotal)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                FilledButton(
                  onPressed:
                  isSubmitting ? null : placeOrder,
                  child: const Text('Place Order'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
