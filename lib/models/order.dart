import 'package:pizza_chef/models/pizza.dart';
import 'package:pizza_chef/models/payment.dart';

class Order {
  const Order({
    required this.pizzas,
    required this.payment,
  });

  final List<Pizza> pizzas;
  final Payment payment;
}
