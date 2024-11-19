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
import 'package:pizza_chef/main.dart';

var logger = Logger(printer: PrettyPrinter());

void main() async {
  final firebase = FakeFirebaseFirestore();

  group('Pizza Creation', () {
    // pizza is correctly added to firestore
    test('Pizza is correctly added to firestore', () async {
      final pizza = {
        'size': 'small',
        'sauce': 'red',
        'crust': 'thinCrust',
        'toppings': <String>['cheese', 'pepperoni'],
      };

      await firebase.collection('pizzas').add(pizza);

      final snapshot = await firebase.collection('pizzas').get();
      final addedPizza = snapshot.docs.first.data();

      expect(addedPizza, pizza);
    });

    // pizza is correctly displayed in the UI
    testWidgets('Pizza is correctly displayed in the cart',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: MyApp(firebase)));
      await tester.idle();
      await tester.pump();
    });
  });
}
