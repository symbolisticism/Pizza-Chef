import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:pizza_chef/widgets/nav_drawer.dart';

var logger = Logger(printer: PrettyPrinter());
final db = FirebaseFirestore.instance;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool stateIsUpdated = false;

  @override
  void initState() {
    super.initState();
    updateState().then((_) {
      setState(() {
        stateIsUpdated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!stateIsUpdated) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizza Chef'),
      ),
      drawer: const NavDrawer('/home'),
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
                    if (await doesntHaveInternetConnection()) {
                      // ensure context is mounted
                      if (context.mounted) {
                        showSnackBar(context,
                            'You are not connected to WiFi or a cellular network. Please connect and try again.');
                      } else {
                        logger.d('Context not mounted');
                        return;
                      }

                      return;
                    }

                    if (context.mounted) {
                      navigateToDefaultOrderForm(context);
                    } else {
                      logger.d('Context not mounted');
                      return;
                    }
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

  Future<bool> doesntHaveInternetConnection() async {
    // check if the device is connected to the internet first
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.wifi) &&
        !connectivityResult.contains(ConnectivityResult.mobile);
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void navigateToDefaultOrderForm(BuildContext context) {
    Navigator.pushReplacementNamed(
      context,
      '/order',  
    );
  }

  Future<void> updateState() async {
    await db.collection('state').doc('1').update({'screen': 'home'});
  }
}
