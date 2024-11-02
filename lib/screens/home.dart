import 'package:flutter/material.dart';
import 'package:pizza_chef/screens/order_form.dart';
import 'package:pizza_chef/screens/cart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

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
                  onPressed: () async {

                    // check if the device is connected to the internet first
                    final List<ConnectivityResult> connectivityResult =
                        await Connectivity().checkConnectivity();

                    if (!connectivityResult.contains(ConnectivityResult.wifi) &&
                        !connectivityResult
                            .contains(ConnectivityResult.mobile)) {
                      if (!context.mounted) {
                        logger.d('Context not mounted');
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'You are not connected to WiFi or a cellular network. Please connect and try again.'),
                        ),
                      );

                      return;
                    }

                    if (!context.mounted) {
                      logger.d('Context not mounted');
                      return;
                    }

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
