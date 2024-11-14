import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pizza_chef/screens/cart.dart';
import 'package:pizza_chef/widgets/shopping_cart_badge.dart';

var logger = Logger(printer: PrettyPrinter());

class NavDrawer extends StatefulWidget {
  const NavDrawer(this.currentScreenName, {super.key});

  final String currentScreenName;

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  late final String currentScreenName;
  final dbStream = FirebaseFirestore.instance.collection('cart').snapshots();

  @override
  void initState() {
    super.initState();
    currentScreenName = widget.currentScreenName;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          TextButton.icon(
            key: const Key('homeButton'),
            onPressed: () {
              if (widget.currentScreenName != '/home') {
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
            key: const Key('orderButton'),
            onPressed: () {
              if (widget.currentScreenName != '/order') {
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
          StreamBuilder<QuerySnapshot>(
            stream: dbStream,
            builder: (context, snapshot) {
              int itemCount = 0;
              if (snapshot.hasData) {
                itemCount = snapshot.data!.docs.length;
              }

              return TextButton.icon(
                key: const Key('cartButton'),
                label: const Text('Cart'),
                onPressed: () {
                  if (widget.currentScreenName != '/cart') {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/cart');
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: ShoppingCartWithBadge(itemCount: itemCount),
              );
            },
          ),
        ],
      ),
    );
  }
}

void navigateToCart(context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const Cart(),
    ),
  );
}
