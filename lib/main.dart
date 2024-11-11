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
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  CollectionReference state = db.collection('state');
  QuerySnapshot snapshot = await state.get();

  String screen = 'home';
  PizzaSize? size;
  PizzaSauce? sauce;
  PizzaCrust? crust;
  List<String>? toppings;
  dynamic lastOpened;

  int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
  int fiveMinutesInMs = 10 *
      1000; // TODO: change this to actually be 5 minutes once functionality is confirmed

  // TODO: In the case that the person started customizing a pizza but didn't ever
  // finish, the state should be cleared here (maybe)

  for (var doc in snapshot.docs) {
    // check if the user's been away for longer than five minutes
    lastOpened = doc.get('lastOpened');

    try {
      lastOpened = int.parse(lastOpened);
    } catch (e) {
      logger.e(e);
    }

    logger.d(lastOpened.runtimeType);

    if (currentTimestamp - lastOpened > fiveMinutesInMs) break;

    // if the user is returning after a short break, restore the previous state
    screen = doc.get('screen');

    if (screen == 'order form') {
      size = doc.get('size');
      sauce = doc.get('sauce');
      crust = doc.get('crust');
      toppings = doc.get('toppings');
    }
  }

  // runApp(
  //   MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     home: screen == 'cart'
  //         ? const Cart()
  //         : screen == 'order form'
  //             ? OrderForm(
  //                 selectedSize: size!,
  //                 selectedCrust: crust!,
  //                 selectedSauce: sauce!,
  //                 selectedToppings: toppings!,
  //               )
  //             : const Home(),
  //   ),
  // );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FutureBuilder(future: loadState, builder: (context, snapshot) {}),
  ));
}

Future<Map<String, String?>> loadState() async {
  return {'hello': null};
}
