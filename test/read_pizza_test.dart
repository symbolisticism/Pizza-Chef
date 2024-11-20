import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_chef/models/pizza.dart';
import 'package:pizza_chef/screens/cart.dart';

void main() async {
  testWidgets('Read Pizza', (WidgetTester tester) async {
    // create fake database
    final firebase = FakeFirebaseFirestore();

    final pizzaMap = {
      'size': 'Medium',
      'sauce': 'White',
      'crust': 'Regular Crust',
      'toppings': <String>['Mushrooms', 'Pepperoni'],
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    final pizza = Pizza.fromMap(pizzaMap);

    // add a pizza
    await firebase.collection('cart').add(pizzaMap);

    // create a state
    await firebase.collection('state').doc('1').set({
      'lastOpened': (DateTime.now().millisecondsSinceEpoch - 40000),
      'screen': 'home',
      'pizzaValues': {
        'size': 'Small',
        'sauce': 'Red',
        'crust': 'Thin Crust',
        'toppings': [],
      },
    });

    // read the pizza from the UI
    await tester.pumpWidget(MaterialApp(
      home: Cart(firestore: firebase),
    ));

    // Let the snapshots stream fire a snapshot
    await tester.pumpAndSettle(); // MONEY SHOT
    await tester.idle(); // MONEY SHOT

    // check if the pizza is displayed
    expect(find.text(pizza.toString()), findsOneWidget);
  });
}
