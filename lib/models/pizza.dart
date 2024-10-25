import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class Pizza {
  Pizza(
      {required this.pizzaSize,
      required this.toppings,
      required this.sauce,
      required this.crustType});

  final PizzaSize pizzaSize;
  final List<String> toppings;
  final PizzaSauce sauce;
  final PizzaCrust crustType;
  final id = uuid.v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'thinCrust': crustType.label,
      'sauce': sauce.label,
      'toppings': toppings,
      'pizzaSize': pizzaSize.label
    };
  }
}
