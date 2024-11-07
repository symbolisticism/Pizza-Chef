import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:pizza_chef/data/toppings.dart';
import 'package:pizza_chef/models/pizza.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());
var db = FirebaseFirestore.instance;

class OrderFormWidget extends StatefulWidget {
  const OrderFormWidget({
    required this.selectedSize,
    required this.selectedSauce,
    required this.selectedCrust,
    required this.selectedToppings,
    this.id,
    this.update,
    super.key,
  });

  final PizzaSize selectedSize;
  final PizzaSauce selectedSauce;
  final PizzaCrust selectedCrust;
  final List<String> selectedToppings;
  final String? id;
  final bool? update;

  @override
  State<OrderFormWidget> createState() => _OrderFormWidgetState();
}

class _OrderFormWidgetState extends State<OrderFormWidget> {
  late PizzaSize selectedSize;
  late PizzaSauce selectedSauce;
  late PizzaCrust selectedCrust;
  late List<String> selectedToppings;
  String? pizzaId;
  bool? pizzaUpdate;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.selectedSize;
    selectedSauce = widget.selectedSauce;
    selectedCrust = widget.selectedCrust;
    selectedToppings = widget.selectedToppings;
    pizzaId = widget.id;
    pizzaUpdate = widget.update;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Try wrapping this column with a SingleChildScrollView to fix rendering on the web
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownMenu<PizzaSize>(
            initialSelection: selectedSize,
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
            initialSelection: selectedSauce,
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
            initialSelection: selectedCrust,
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
          // TODO: Clear the changes to the toppings after the user exits without saving
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: toppings.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  tristate: false,
                  title: Text(toppings[index]),
                  value: selectedToppings.contains(toppings[index]),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedToppings.add(toppings[index]);
                      } else {
                        selectedToppings.remove(toppings[index]);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  // get the current time
                  final now = DateTime.now();
      
                  // sort the list to make it easier to compare later
                  selectedToppings = (selectedToppings..sort()).toList();
      
                  // create the pizza object
                  Pizza pizza = Pizza(
                    pizzaSize: selectedSize,
                    toppings: selectedToppings,
                    sauce: selectedSauce,
                    crustType: selectedCrust,
                    timestamp: now,
                  );
      
                  // get number of pizzas in the cart
                  CollectionReference cart = db.collection('cart');
                  QuerySnapshot snapshot = await cart.get();
                  int numberOfPizzas = snapshot.docs.length;
      
                  // if the order is full
                  if (numberOfPizzas >= 5) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'You have reached the limit of pizzas. Please remove one before creating another one.'),
                      ),
                    );
                    return;
                  }
      
                  // check if an identical pizza already exists in the database
                  for (var doc in snapshot.docs) {
                    final recordPizzaSize = doc.get('pizzaSize') as String;
                    final recordSauce = doc.get('sauce') as String;
                    final recordCrust = doc.get('thinCrust') as String;
      
                    // list manipulation for comparison
                    dynamic recordToppings = doc.get('toppings') as List<dynamic>;
                    recordToppings = List<String>.from(recordToppings);
                    recordToppings = (recordToppings..sort()).toList();
      
                    if (pizza.pizzaSize.label == recordPizzaSize &&
                        pizza.sauce.label == recordSauce &&
                        pizza.crustType.label == recordCrust &&
                        const ListEquality()
                            .equals(recordToppings, pizza.toppings)) {
                      // check if context is mounted
                      if (!context.mounted) {
                        logger.d('Context not mounted');
                        return;
                      }
                      // tell user that there's already an identical pizza in the cart
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'An identical pizza is already in your cart. Please make this one unique before proceeding.'),
                        ),
                      );
      
                      return;
                    }
                  }
      
                  try {
                    if (pizzaUpdate != null &&
                        pizzaUpdate! &&
                        pizzaId != null &&
                        pizzaId!.isNotEmpty) {
                      await db.collection('cart').doc(pizzaId).update({
                        'pizzaSize': selectedSize.label,
                        'sauce': selectedSauce.label,
                        'thinCrust': selectedCrust.label,
                        'toppings': selectedToppings,
                        'timestamp': now,
                      });
                    } else {
                      await db
                          .collection('cart')
                          .doc(pizza.id)
                          .set(pizza.toMap());
                    }
                  } catch (e) {
                    logger.e(e);
                  }
      
                  if (!context.mounted) {
                    logger.e("Context not mounted");
                    return;
                  }
      
                  if (pizzaUpdate != null && pizzaUpdate!) {
                    Navigator.of(context).pop(true);
                  } else {
                    Navigator.of(context).pop(false);
                  }
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text((pizzaUpdate != null && pizzaUpdate!)
                          ? 'You have successfully updated your pizza.'
                          : 'Your pizza has been successfully added.'),
                    ),
                  );
                },
                child: Text((pizzaUpdate != null && pizzaUpdate!)
                    ? 'Update Pizza'
                    : 'Add to Cart'),
              ),
              if (pizzaUpdate != null && pizzaUpdate!) ...[
                const Spacer(),
                TextButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete this pizza?'),
                            content: const Text(
                                'Are you sure you want to delete this pizza? This action cannot be undone.'),
                            actions: [
                              ElevatedButton(
                                onPressed: () async {
                                  await db
                                      .collection('cart')
                                      .doc(pizzaId)
                                      .delete();
                                  if (!context.mounted) {
                                    logger.d('Context not mounted');
                                    return;
                                  }
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop(true);
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Your pizza was deleted.'),
                                    ),
                                  );
                                },
                                child: const Text('Delete Pizza'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Delete Pizza')),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
