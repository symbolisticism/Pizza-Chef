import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_chef/models/pizza.dart';
import 'package:pizza_chef/screens/cart.dart';

void main() async {
  // instantiate a fake database
  final firebase = FakeFirebaseFirestore();

  final timestamp = DateTime.now().millisecondsSinceEpoch;

  // create a pizza
  final pizzaMap = {
    'size': 'Medium',
    'sauce': 'White',
    'crust': 'Regular Crust',
    'toppings': <String>['Mushrooms', 'Pepperoni'],
    'timestamp': timestamp,
  };

  Pizza pizza = Pizza.fromMap(pizzaMap);

  // add pizza to database
  await firebase.collection('cart').add(pizzaMap);

  // create a state
  final state = {
    'lastOpened': (DateTime.now().millisecondsSinceEpoch - 40000),
    'screen': 'home',
    'pizzaValues': {
      'size': 'Small',
      'sauce': 'Red',
      'crust': 'Thin Crust',
      'toppings': [],
    },
  };

  // add state to the database
  await firebase.collection('state').doc('1').set(state);

  testWidgets('Delete Pizza', (WidgetTester tester) async {
    // start the app
    await tester.pumpWidget(MaterialApp(
      home: Cart(firestore: firebase),
    ));

    // let the app render
    await tester.pumpAndSettle(); // MONEY SHOT
    await tester.idle(); // MONEY SHOT

    // tap on the edit button on the first item in the list
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    // tap on the delete button
    await tester.dragUntilVisible(find.byKey(const Key('Delete Button')),
        find.byType(SingleChildScrollView), const Offset(0, 50));
    await tester.tap(find.byKey(const Key('Delete Button')));
    await tester.pumpAndSettle();

    // tap the button on the dialog box
    await tester.tap(find.byKey(const Key('Dialog Box Delete Button')));
    await tester.pumpAndSettle();

    // check that the pizza was deleted in the database
    final snapshot = await firebase.collection('cart').get();
    final updatedPizza = snapshot.docs;
    expect(updatedPizza.length, 0);

    // check that the pizza was deleted from the UI
    expect(find.text(pizza.toString()), findsNothing);
  });
}
