import 'package:flutter/material.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_chef/widgets/order_form_widget.dart';

var logger = Logger(printer: PrettyPrinter());
final db = FirebaseFirestore.instance;

class OrderForm extends StatefulWidget {
  OrderForm.defaultOrder({super.key})
      : selectedSize = PizzaSize.small,
        selectedSauce = PizzaSauce.red,
        selectedCrust = PizzaCrust.thinCrust,
        selectedToppings = [];

  // constructor that will take parameters
  const OrderForm({
    required this.selectedSize,
    required this.selectedSauce,
    required this.selectedCrust,
    required this.selectedToppings,
    super.key,
  });

  final PizzaSize selectedSize;
  final PizzaSauce selectedSauce;
  final PizzaCrust selectedCrust;
  final List<String> selectedToppings;

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  late PizzaSize selectedSize;
  late PizzaSauce selectedSauce;
  late PizzaCrust selectedCrust;
  late List<String> selectedToppings;
  bool stateIsUpdated = false;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.selectedSize;
    selectedSauce = widget.selectedSauce;
    selectedCrust = widget.selectedCrust;
    selectedToppings = widget.selectedToppings;
    updateState().then((_) {
      setState(() {
        stateIsUpdated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!stateIsUpdated) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await db.collection('state').doc('1').update({'screen': 'home'});
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: OrderFormWidget(
              selectedSize: selectedSize,
              selectedSauce: selectedSauce,
              selectedCrust: selectedCrust,
              selectedToppings: selectedToppings,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateState() async {
    await db.collection('state').doc('1').update({'screen': 'order form'});
  }
}
