import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
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

    final newPizza = Pizza(
      pizzaSize: PizzaSize.medium,
      toppings: ['Mushrooms'],
      sauce: PizzaSauce.white,
      crustType: PizzaCrust.regularCrust,
      timestamp: timestamp,
    );

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
  testWidgets('Update Pizza', (WidgetTester tester) async {

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

    // uncheck the first topping
    await tester.tap(find.byKey(const Key('Pepperoni')));
    await tester.pumpAndSettle();

    // tap on the save button
    await tester.dragUntilVisible(find.byKey(const Key('Submit Button')),
        find.byType(SingleChildScrollView), const Offset(0, 50));
    await tester.tap(find.byKey(const Key('Submit Button')));
    await tester.pumpAndSettle();

    // check that the pizza was updated in the database
    final snapshot = await firebase.collection('cart').get();
    final updatedPizza = snapshot.docs.first.data();
    expect(updatedPizza['toppings'], ['Mushrooms']);

    // check that the pizza was updated in the UI
    expect(find.text(newPizza.toString()), findsOneWidget);
  });
}
