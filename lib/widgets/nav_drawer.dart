import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

class NavDrawer extends StatelessWidget {
  const NavDrawer(this.currentScreenName, {super.key});

  final String currentScreenName;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          TextButton.icon(
            onPressed: () {
              if (currentScreenName != '/home') {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                Navigator.pop(context);
              }
            },
            label: const Text('Home'),
            icon: const Icon(Icons.home),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () {
              if (currentScreenName != '/order') {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/order');
              } else {
                Navigator.pop(context);
              }
            },
            label: const Text('Order Form'),
            icon: const Icon(Icons.list_alt),
          ),
          const SizedBox(height: 20),
          // TODO: See if I can replace this with the shopping cart icon
          // that's currently on the home screen
          TextButton.icon(
            onPressed: () {
              if (currentScreenName != '/cart') {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/cart');
              } else {
                Navigator.pop(context);
              }
            },
            label: const Text('Cart'),
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),
    );
  }
}
