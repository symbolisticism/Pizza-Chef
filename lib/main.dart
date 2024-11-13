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
  void initState() {
    super.initState();
    initializeState();
  }

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

              switch (data['screen']) {
                case 'cart':
                  return const Cart();
                case 'order form':
                  // convert values back to correct data types
                  Map<String, dynamic> newPizzaValues =
                      convertPizzaValues(data['pizzaValues']);

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

  Future<void> resetState(int currentTime) async {
    // current time
    Map<String, dynamic> resetValues = {
      'lastOpened': currentTime,
      'screen': 'home',
      'pizzaValues': {
        'crust': 'Thin Crust',
        'sauce': 'Red',
        'size': 'Small',
        'toppings': [],
      }
    };
    await db.collection('state').doc('1').update(resetValues);
  }

  Map<String, dynamic> convertPizzaValues(Map<String, dynamic> pizzaValues) {
    PizzaSize size;
  switch (pizzaValues['size']) {
    case 'Small':
      size = PizzaSize.small;
      break;
    case 'Medium':
      size = PizzaSize.medium;
      break;
    case 'Large':
      size = PizzaSize.large;
      break;
    default:
      size = PizzaSize.small; // Default value
  }

  PizzaSauce sauce;
  switch (pizzaValues['sauce']) {
    case 'Red':
      sauce = PizzaSauce.red;
      break;
    case 'White':
      sauce = PizzaSauce.white;
      break;
    default:
      sauce = PizzaSauce.red; // Default value
  }

  PizzaCrust crust;
  switch (pizzaValues['crust']) {
    case 'Thin Crust':
      crust = PizzaCrust.thinCrust;
      break;
    case 'Regular Crust':
      crust = PizzaCrust.regularCrust;
      break;
    default:
      crust = PizzaCrust.thinCrust; // Default value
  }

  List<String> toppings = pizzaValues['toppings'] != null
      ? List<String>.from(pizzaValues['toppings'])
      : <String>[];

  return {
    'size': size,
    'crust': crust,
    'sauce': sauce,
    'toppings': toppings,
  };
  }

  Future<void> initializeState() async {
    DocumentSnapshot snapshot = await db.collection('state').doc('1').get();
    final lastOpened = snapshot.get('lastOpened') as int;
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int elapsedTime = currentTime - lastOpened;
    int fiveMinutes = 5 * 60 * 1000; // 5 minutes in milliseconds

    if (elapsedTime > fiveMinutes) {
      resetState(currentTime);
    } else {
      await db.collection('state').doc('1').update({'lastOpened': currentTime});
    }
  }
}
