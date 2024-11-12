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
  runApp(MaterialApp(
    routes: {
      '/home': (context) => const Home(),
      '/cart': (context) => const Cart(),
      '/order': (context) => OrderForm.defaultOrder(),
    },
    debugShowCheckedModeBanner: false,
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Map<String, dynamic>> lastState;
  bool initializationComplete = false;

  @override
  void initState() {
    super.initState();

    // app initialization
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false);
    });
    initializeFirebase().then((_) {
      lastState = loadState();
      setState(() {
        initializationComplete = true;
      });
    });

    // load in state
    // lastState = loadState();
  }

  @override
  Widget build(BuildContext context) {
    if (!initializationComplete) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
          future: lastState,
          builder: (context, snapshot) {
            // error
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.hasData) {
              Map<String, dynamic>? data = snapshot.data;

              if (data != null) {
                shouldResetLastState(data['lastOpened']);

                // TODO: ensure the home screen is always on the bottom of the stack
                // TODO: currently, the app remembers the state and delivers the
                // TODO: relevant screen, but if it delivers the cart or order
                // TODO: form page, there is no way to navigate back to home

                switch (data['screen']) {
                  case 'cart':
                    return const Cart();
                  case 'order form':
                    // convert values back to correct data types
                    Map<String, dynamic> newPizzaValues =
                        convertPizzaValues(data);

                    return OrderForm(
                        selectedSize: newPizzaValues['size'],
                        selectedSauce: newPizzaValues['sauce'],
                        selectedCrust: newPizzaValues['crust'],
                        selectedToppings: newPizzaValues['toppings']);
                  default:
                    return const Home();
                }
              } else {
                return const Center(child: Text('Data is null.'));
              }
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  Future<Map<String, dynamic>> loadState() async {
    QuerySnapshot querySnapshot = await db.collection('state').get();
    Map<String, dynamic> lastState = {};

    for (var doc in querySnapshot.docs) {
      lastState['screen'] = doc.get('screen');
      lastState['pizzaValues'] = doc.get('pizzaValues');
      lastState['lastOpened'] = doc.get('lastOpened');
    }

    return lastState;
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  bool shouldResetLastState(int timestamp) {
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    int fiveMinutes = 10 *
        1000; // TODO: change this back to five minutes after testing, currently 10 seconds
    int timeElapsed = currentTimestamp - timestamp;

    if (timeElapsed > fiveMinutes) {
      resetState();
      return true;
    }

    return false;
  }

  Future<void> resetState() async {
    // current time
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> resetValues = {
      'lastOpened': currentTime,
      'screen': 'home',
      // TODO: determine if null is the best value to reset the values to
      'pizzaValues': {
        'crust': 'thin crust',
        'sauce': 'red',
        'size': 'small',
        'toppings': [],
      }
    };
    await db.collection('state').doc('1').set(resetValues);
  }

  Map<String, dynamic> convertPizzaValues(Map<String, dynamic> pizzaValues) {
    PizzaSize size = pizzaValues['size'] == 'small'
        ? PizzaSize.small
        : pizzaValues['size'] == 'medium'
            ? PizzaSize.medium
            : PizzaSize.large;

    PizzaSauce sauce =
        pizzaValues['sauce'] == 'red' ? PizzaSauce.red : PizzaSauce.white;

    PizzaCrust crust = pizzaValues['crust'] == 'thin crust'
        ? PizzaCrust.thinCrust
        : PizzaCrust.regularCrust;

    dynamic toppings = pizzaValues['toppings'];
    toppings = List<String>.from(toppings);
    toppings = (toppings..sort()).toList();

    return {
      'size': size,
      'crust': crust,
      'sauce': sauce,
      'toppings': toppings,
    };
  }
}
