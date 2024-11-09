import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class Pizza {
  Pizza({
    required this.pizzaSize,
    required this.toppings,
    required this.sauce,
    required this.crustType,
    required this.timestamp,
  }) : id = uuid.v1();

  Pizza.withId({
    required this.pizzaSize,
    required this.toppings,
    required this.sauce,
    required this.crustType,
    required this.timestamp,
    required this.id,
  });

  final PizzaSize pizzaSize;
  final List<String> toppings;
  final PizzaSauce sauce;
  final PizzaCrust crustType;
  final String id;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return {
      'thinCrust': crustType.label,
      'sauce': sauce.label,
      'toppings': toppings,
      'pizzaSize': pizzaSize.label,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return "${pizzaSize.label} pizza with ${sauce.label} sauce, ${crustType.label}, and the following toppings: ${toppings.join(', ')}";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Pizza) {
      return pizzaSize == other.pizzaSize &&
          toppings == other.toppings &&
          sauce == other.sauce &&
          crustType == other.crustType;
    }

    return false;
  }

  @override
  @override
  int get hashCode =>
      crustType.hashCode ^
      sauce.hashCode ^
      pizzaSize.hashCode ^
      toppings.hashCode;
}
