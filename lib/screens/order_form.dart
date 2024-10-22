import 'package:flutter/material.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:pizza_chef/data/toppings.dart';
import 'package:logger/logger.dart';
import 'package:pizza_chef/models/pizza.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var logger = Logger(printer: PrettyPrinter());
final db = FirebaseFirestore.instance;

class OrderForm extends StatefulWidget {
  const OrderForm({super.key});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final _formKey = GlobalKey<FormState>();
  final sizeController = TextEditingController();
  final sauceController = TextEditingController();
  final crustController = TextEditingController();
  PizzaSize selectedSize = PizzaSize.small;
  PizzaSauce selectedSauce = PizzaSauce.red;
  PizzaCrust selectedCrust = PizzaCrust.thinCrust;
  List<String>? selectedToppings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order'),
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownMenu<PizzaSize>(
                  initialSelection: PizzaSize.small,
                  controller: sizeController,
                  requestFocusOnTap: true,
                  label: const Text('Pizza Size'),
                  onSelected: (PizzaSize? size) {
                    setState(() {
                      selectedSize = size!;
                    });
                  },
                  dropdownMenuEntries: PizzaSize.values
                      .map<DropdownMenuEntry<PizzaSize>>((PizzaSize size) {
                    return DropdownMenuEntry<PizzaSize>(
                      value: size,
                      label: size.label,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),
                DropdownMenu<PizzaSauce>(
                  initialSelection: PizzaSauce.red,
                  controller: sauceController,
                  requestFocusOnTap: true,
                  label: const Text('Pizza Sauce'),
                  onSelected: (PizzaSauce? sauce) {
                    setState(() {
                      selectedSauce = sauce!;
                    });
                  },
                  dropdownMenuEntries: PizzaSauce.values
                      .map<DropdownMenuEntry<PizzaSauce>>((PizzaSauce sauce) {
                    return DropdownMenuEntry<PizzaSauce>(
                      value: sauce,
                      label: sauce.label,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),
                DropdownMenu<PizzaCrust>(
                  initialSelection: PizzaCrust.thinCrust,
                  controller: crustController,
                  requestFocusOnTap: true,
                  label: const Text('Pizza Crust'),
                  onSelected: (PizzaCrust? crust) {
                    setState(() {
                      selectedCrust = crust!;
                    });
                  },
                  dropdownMenuEntries: PizzaCrust.values
                      .map<DropdownMenuEntry<PizzaCrust>>((PizzaCrust crust) {
                    return DropdownMenuEntry<PizzaCrust>(
                      value: crust,
                      label: crust.label,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),
                const Text('Scroll through the toppings:'),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: toppings.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        tristate: false,
                        title: Text(toppings[index]),
                        value: selectedToppings?.contains(toppings[index]),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedToppings?.add(toppings[index]);
                            } else {
                              selectedToppings?.remove(toppings[index]);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // check how many pizzas are in the cart
                    CollectionReference cart = db.collection('cart');
                    QuerySnapshot snapshot = await cart.get();
                    int numberOfPizzas = snapshot.docs.length;

                    // if the order is full
                    if (numberOfPizzas >= 5) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'You have reached the limit of pizzas. Please remove one before creating another one.'),
                        ),
                      );
                      return;
                    }
                    

                    Pizza pizza = Pizza(
                        pizzaSize: selectedSize,
                        toppings: selectedToppings!,
                        sauce: selectedSauce,
                        thinCrust: selectedCrust);
                    db.collection('cart').add(pizza.toMap());
                  },
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
          ),
      ),
    );
  }

  @override
  void dispose() {
    sizeController.dispose();
    sauceController.dispose();
    crustController.dispose();
    super.dispose();
  }
}
