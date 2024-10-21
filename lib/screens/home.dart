import 'package:flutter/material.dart';
import 'package:pizza_chef/screens/order_form.dart';
import 'package:pizza_chef/screens/cart.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizza Chef'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Cart(),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 86),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Create a new pizza order!'),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OrderForm(),
                      ),
                    );
                  },
                  child: const Text('Start Here'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
