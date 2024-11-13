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

// todo: make sure the 'lastOpened' variable gets updated every time the app is
// initialized, regardless of whether the state gets reset or not

void main() async {

  // app initialization
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

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

  @override
  Widget build(BuildContext context) {
    final dbStream = db.collection('state').doc('1').snapshots();

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream: dbStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.hasData) {
              final data = snapshot.data!.data() as Map<String, dynamic>;

              shouldResetLastState(data['lastOpened'] as int);

              switch (data['screen']) {
                case 'cart':
                  return const Cart();
                case 'order form':
                  // convert values back to correct data types
                  logger.d(data);
                  Map<String, dynamic> newPizzaValues = convertPizzaValues(data);

                  return OrderForm(
                      selectedSize: newPizzaValues['size'] as PizzaSize,
                      selectedSauce: newPizzaValues['sauce'] as PizzaSauce,
                      selectedCrust: newPizzaValues['crust'] as PizzaCrust,
                      selectedToppings:
                          newPizzaValues['toppings'] as List<String>);
                default:
                  return const Home();
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
    int fiveMinutes = 60 *
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
      'lastOpened' : currentTime,
      'screen': 'home',
      'pizzaValues': {
        'crust': 'thin crust',
        'sauce': 'red',
        'size': 'small',
        'toppings': [],
      }
    };
    await db.collection('state').doc('1').update(resetValues);
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
