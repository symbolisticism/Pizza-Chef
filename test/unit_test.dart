// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:pizza_chef/main.dart';

void main() {
  test('Check that pizza values are converted correctly', () {
    final initialValues = {
      'size': 'small',
      'sauce': 'red',
      'crust': 'thinCrust',
      'toppings': <dynamic>['cheese', 'pepperoni'],
    };

    final convertedValues = convertPizzaValues(initialValues);

    expect(convertedValues, {
      'size': PizzaSize.small,
      'sauce': PizzaSauce.red,
      'crust': PizzaCrust.thinCrust,
      'toppings': <String>['cheese', 'pepperoni'],
    });
  });

  
}
