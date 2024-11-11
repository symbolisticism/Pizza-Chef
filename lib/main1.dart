import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:pizza_chef/screens/cart.dart';
import 'package:pizza_chef/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:pizza_chef/screens/order_form.dart';
import 'package:logger/logger.dart';

var db = FirebaseFirestore.instance;
var logger = Logger(printer: PrettyPrinter());

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Map<String, dynamic>> lastState;

  @override
  void initState() {
    super.initState();

    // app initialization
    WidgetsFlutterBinding.ensureInitialized();
    initializeFirebase();

    // load in state
    lastState = loadState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
          future: lastState,
          builder: (context, snapshot) {
            // loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // error
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.hasData) {
              Map<String, dynamic>? data = snapshot.data;

              if (data != null) {
                switch (data['screen']) {
                  case 'home':
                    return const Home();
                  case 'cart':
                    return const Cart();
                  case 'order form':
                    PizzaSize size = data['size'] == 'small'
                        ? PizzaSize.small
                        : data['size'] == 'medium'
                            ? PizzaSize.medium
                            : PizzaSize.large;

                    PizzaSauce sauce = data['sauce'] == 'red'
                        ? PizzaSauce.red
                        : PizzaSauce.white;

                    PizzaCrust crust = data['crust'] == 'thin crust'
                        ? PizzaCrust.thinCrust
                        : PizzaCrust.regularCrust;

                    dynamic toppings = data['toppings'];
                    toppings = List<String>.from(toppings);
                    toppings = (toppings..sort()).toList();

                    return OrderForm(
                        selectedSize: size,
                        selectedSauce: sauce,
                        selectedCrust: crust,
                        selectedToppings: toppings);
                  default:
                }
              }
            }
          }),
    );
  }

  Future<Map<String, dynamic>> loadState() async {
    return {'hello': null};
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
