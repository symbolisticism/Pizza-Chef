import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:pizza_chef/main.dart';

void main() {
  // tests the conversion of pizza values
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