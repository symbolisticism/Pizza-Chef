// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:pizza_chef/models/pizza.dart';
import 'package:pizza_chef/screens/cart.dart';

var logger = Logger(printer: PrettyPrinter());

void main() async {
  final firebase = FakeFirebaseFirestore();
  final pizzaMap = {
    'size': 'Small',
    'sauce': 'Red',
    'crust': 'Thin Crust',
    'toppings': <String>['Mushrooms', 'Pepperoni'],
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };

  // set the state
  await firebase.collection('state').doc('1').set({
    'screen': 'home',
    'lastOpened': DateTime.now().millisecondsSinceEpoch,
    'pizzaValues': {
      'crust': 'Thin Crust',
      'sauce': 'Red',
      'size': 'Small',
      'toppings': [],
    }
  });

    // pizza is correctly added to firestore
    test('Create Pizza', () async {
      await firebase.collection('pizzas').add(pizzaMap);

      final snapshot = await firebase.collection('pizzas').get();
      final addedPizza = snapshot.docs.first.data();

      expect(addedPizza, pizzaMap);
    });
}
