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
  late Future<Map<String, Object>> lastState;
  bool initializationComplete = false;

  @override
  void initState() {
    super.initState();

    // app initialization
    WidgetsFlutterBinding.ensureInitialized();
    initializeFirebase().then((_) {
      lastState = loadState();
      setState(() {
        initializationComplete = true;
      });
    });
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
      body: FutureBuilder<Map<String, Object>>(
          future: lastState,
          builder: (context, snapshot) {
            // error
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.hasData) {
              Map<String, Object>? data = snapshot.data;

              if (data != null) {
                shouldResetLastState(data['lastOpened'] as int);

                switch (data['screen']) {
                  case 'cart':
                    return const Cart();
                  case 'order form':
                    // convert values back to correct data types
                    logger.d(data);
                    Map<String, Object> newPizzaValues =
                        convertPizzaValues(data);

                    return OrderForm(
                        selectedSize: newPizzaValues['size'] as PizzaSize,
                        selectedSauce: newPizzaValues['sauce'] as PizzaSauce,
                        selectedCrust: newPizzaValues['crust'] as PizzaCrust,
                        selectedToppings:
                            newPizzaValues['toppings'] as List<String>);
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

  Future<Map<String, Object>> loadState() async {
    QuerySnapshot querySnapshot = await db.collection('state').get();
    Map<String, Object> lastState = {};

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
    int fiveMinutes = 20 *
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
    Map<String, Object> resetValues = {
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

  Map<String, Object> convertPizzaValues(Map<String, Object> pizzaValues) {
    // TODO: I believe the NULL error is coming from in here
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
    if (toppings != null) {
      toppings = List<String>.from(toppings);
      toppings = (toppings..sort()).toList();
    } else {
      toppings = <String>[];
    }

    return {
      'size': size,
      'crust': crust,
      'sauce': sauce,
      'toppings': toppings,
    };
  }
}
