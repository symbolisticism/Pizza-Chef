import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:pizza_chef/data/toppings.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

var logger = Logger(printer: PrettyPrinter());
var uuid = const Uuid();

class OrderFormWidget extends StatefulWidget {
  const OrderFormWidget({
    required this.selectedSize,
    required this.firestore,
    required this.selectedSauce,
    required this.selectedCrust,
    required this.selectedToppings,
    this.id,
    this.update,
    super.key,
  });

  final FirebaseFirestore firestore;
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

  // temp variables in case of an update
  late List<String>? tempSelectedToppings;
  late PizzaSize? tempPizzaSize;
  late PizzaSauce? tempPizzaSauce;
  late PizzaCrust? tempPizzaCrust;

  // optional parameters for an update
  String? pizzaId;
  bool? pizzaUpdate;

  // loading
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.selectedSize;
    selectedSauce = widget.selectedSauce;
    selectedCrust = widget.selectedCrust;
    selectedToppings = widget.selectedToppings;
    pizzaId = widget.id;
    pizzaUpdate = widget.update;

    if (pizzaUpdate != null && pizzaUpdate!) {
      tempSelectedToppings = List.from(selectedToppings);
      tempPizzaSize = selectedSize;
      tempPizzaSauce = selectedSauce;
      tempPizzaCrust = selectedCrust;
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore db = widget.firestore;
    bool validPizzaUpdate = (pizzaUpdate != null && pizzaUpdate!);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // pizza size dropdown
          DropdownMenu<PizzaSize>(
            key: const Key('pizzaSizeDropdown'),
            initialSelection: validPizzaUpdate ? tempPizzaSize : selectedSize,
            label: const Text('Pizza Size'),
            onSelected: (PizzaSize? size) async {
              setState(() {
                if (validPizzaUpdate) {
                  tempPizzaSize = size;
                } else {
                  selectedSize = size!;
                  // update state
                }
              });

              // update the database
              await db
                  .collection('state')
                  .doc('1')
                  .update({'pizzaValues.size': size!.label});
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
          // pizza sauce dropdown
          DropdownMenu<PizzaSauce>(
            key: const Key('pizzaSauceDropdown'),
            initialSelection: validPizzaUpdate ? tempPizzaSauce : selectedSauce,
            label: const Text('Pizza Sauce'),
            onSelected: (PizzaSauce? sauce) async {
              setState(() {
                if (validPizzaUpdate) {
                  tempPizzaSauce = sauce!;
                } else {
                  selectedSauce = sauce!;
                }
              });

              // update state
              await db
                  .collection('state')
                  .doc('1')
                  .update({'pizzaValues.sauce': sauce!.label});
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
          // pizza crust dropdown
          DropdownMenu<PizzaCrust>(
            key: const Key('pizzaCrustDropdown'),
            initialSelection: validPizzaUpdate ? tempPizzaCrust : selectedCrust,
            label: const Text('Pizza Crust'),
            onSelected: (PizzaCrust? crust) async {
              setState(() {
                if (validPizzaUpdate) {
                  tempPizzaCrust = crust!;
                } else {
                  selectedCrust = crust!;
                }
              });

              // update state
              await db
                  .collection('state')
                  .doc('1')
                  .update({'pizzaValues.crust': crust!.label});
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
          // Sized box containing toppings list
          SizedBox(
            height: 300,
            child: ListView.builder(
              key: const Key('toppingsList'),
              itemCount: toppings.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  key: Key(toppings[index]),
                  tristate: false,
                  title: Text(toppings[index]),
                  value: validPizzaUpdate
                      ? tempSelectedToppings!.contains(toppings[index])
                      : selectedToppings.contains(toppings[index]),
                  onChanged: (bool? value) async {
                    setState(() {
                      if (value == true) {
                        if (validPizzaUpdate) {
                          tempSelectedToppings!.add(toppings[index]);
                        } else {
                          selectedToppings.add(toppings[index]);
                        }
                      } else {
                        if (validPizzaUpdate) {
                          tempSelectedToppings!.remove(toppings[index]);
                        } else {
                          selectedToppings.remove(toppings[index]);
                        }
                      }
                    });

                    // Perform the database operations outside of setState
                    if (value == true) {
                      // don't update the state for pizza creation
                      if (!validPizzaUpdate) {
                        await db.collection('state').doc('1').update({
                          'pizzaValues.toppings':
                              FieldValue.arrayUnion([toppings[index]])
                        });
                      }
                    } else {
                      if (!validPizzaUpdate) {
                        await db.collection('state').doc('1').update({
                          'pizzaValues.toppings':
                              FieldValue.arrayRemove([toppings[index]])
                        });
                      }
                    }
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                key: const Key('Submit Button'),
                onPressed: () async {
                  // pizza map for comparison
                  final Map<String, dynamic> pizzaMap;
                  if (validPizzaUpdate) {
                    pizzaMap = {
                      'size': tempPizzaSize!.label,
                      'sauce': tempPizzaSauce!.label,
                      'crust': tempPizzaCrust!.label,
                      'toppings': (tempSelectedToppings!..sort()).toList()
                    };
                  } else {
                    pizzaMap = {
                      'size': selectedSize.label,
                      'sauce': selectedSauce.label,
                      'crust': selectedCrust.label,
                      'toppings': (selectedToppings..sort()).toList(),
                    };
                  }

                  // TODO: future work -> separate logic between update and creation from the top of the widget
                  // todo: rather than using the validPizzaUpdate variable to check if the pizza is being updated
                  // todo: and doing everything twice
                  // 1. check if the cart is full
                  if (!validPizzaUpdate) {
                    if (await cartIsFull(db)) {
                      if (context.mounted) {
                        showSnackBar(context,
                            'You have reached the limit of pizzas. Please remove one before creating another one.');
                      } else {
                        logger.d('Context not mounted');
                      }
                      return;
                    }
                  }

                  // 2. check if there's an identical pizza in the database
                  if (await thereIsAnIdenticalPizza(pizzaMap, db)) {
                    if (context.mounted) {
                      if (validPizzaUpdate) {
                        showIdenticalPizzaDialog(
                            context); // TODO: this is showing even when valid changes have been made
                      } else {
                        showSnackBar(context,
                            'An identical pizza is already in your cart. Please make this one unique before proceeding.');
                      }
                    } else {
                      logger.d('Context not mounted');
                    }
                    return;
                  }

                  // 3. submit the pizza to the database
                  bool validPizzaId = pizzaId != null && pizzaId!.isNotEmpty;

                  // create the pizza map to be sent to the database
                  pizzaMap['timestamp'] = DateTime.now().millisecondsSinceEpoch;

                  if (!validPizzaUpdate) {
                    try {
                      // add a new pizza to the database
                      await db.collection('cart').doc(uuid.v1()).set(pizzaMap);

                      // reset the state
                      await db.collection('state').doc('1').update({
                        'pizzaValues': {
                          'crust': 'Thin Crust',
                          'sauce': 'Red',
                          'size': 'Small',
                          'toppings': [],
                        }
                      });
                    } catch (e) {
                      logger.e(e);
                    }
                  } else {
                    if (validPizzaId) {
                      // update the pizza
                      try {
                        await db
                            .collection('cart')
                            .doc(pizzaId)
                            .update(pizzaMap);
                      } catch (e) {
                        logger.e(e);
                      }
                    } else {
                      logger.d('Invalid Pizza ID.');
                      return;
                    }
                  }

                  // TODO: This is not navigating and showing the snackbar correctly
                  if (context.mounted) {
                    if (validPizzaUpdate) {
                      // true means the pizza was updated
                      Navigator.pop(
                          context, true); // TODO: I'm not done with this
                    } else {
                      // false means the pizza was added
                      Navigator.pushReplacementNamed(context, '/home');
                    }

                    showSnackBar(
                        context,
                        validPizzaUpdate
                            ? 'You have successfully updated your pizza.'
                            : 'Your pizza has been successfully added.');
                  } else {
                    logger.e("Context not mounted");
                    return;
                  }
                },
                child: Text(validPizzaUpdate ? 'Update Pizza' : 'Add to Cart'),
              ),
              if (validPizzaUpdate) ...[
                const Spacer(),
                TextButton(
                  key: const Key('cancelButton'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                TextButton(
                  key: const Key('Delete Button'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () {
                    showDeletePizzaDialog(context, db);
                  },
                  child: const Text('Delete Pizza'),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void showIdenticalPizzaDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Identical Pizza Found'),
            content: const Text(
                "Either no changes have been made, or an identical pizza already exists in your cart. Please make this pizza unique before proceeding."),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  void showDeletePizzaDialog(BuildContext context, FirebaseFirestore db) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete this pizza?'),
          content: const Text(
              'Are you sure you want to delete this pizza? This action cannot be undone.'),
          actions: [
            ElevatedButton(
              key: const Key('Dialog Box Delete Button'),
              onPressed: () async {
                await db.collection('cart').doc(pizzaId).delete();
                if (!context.mounted) {
                  logger.d('Context not mounted');
                  return;
                }
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
                showSnackBar(context, 'Your pizza was deleted.');
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
  }
}

// PURE FUNCTIONS
Future<bool> cartIsFull(FirebaseFirestore db) async {
  CollectionReference cart = db.collection('cart');
  QuerySnapshot snapshot = await cart.get();

  return snapshot.docs.length >= 5;
}

Future<bool> thereIsAnIdenticalPizza(
    Map<String, dynamic> pizzaMap, FirebaseFirestore db) async {
  // Query Firestore to find a matching document
  final querySnapshot = await db
      .collection('cart')
      .where("size", isEqualTo: pizzaMap["size"])
      .where("sauce", isEqualTo: pizzaMap["sauce"])
      .where("crust", isEqualTo: pizzaMap["crust"])
      .where("toppings", isEqualTo: pizzaMap["toppings"])
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    return true;
  }

  return false;
}
