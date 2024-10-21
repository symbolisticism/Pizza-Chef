import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';

class Pizza {
  const Pizza(
      {required this.pizzaSize,
      required this.toppings,
      required this.sauce,
      required this.thinCrust});

  final PizzaSize pizzaSize;
  final List<String> toppings;
  final PizzaSauce sauce;
  final bool thinCrust;
}
