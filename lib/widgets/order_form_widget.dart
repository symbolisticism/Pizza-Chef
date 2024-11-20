import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:pizza_chef/data/toppings.dart';
import 'package:pizza_chef/models/pizza.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

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
    // get the firestore instance
    FirebaseFirestore db = widget.firestore;

    bool validPizzaUpdate = (pizzaUpdate != null && pizzaUpdate!);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // pizza size dropdown
          DropdownMenu<PizzaSize>(
            key: const Key('pizzaSizeDropdown'),
            initialSelection: selectedSize,
            label: const Text('Pizza Size'),
            onSelected: (PizzaSize? size) {
              setState(() async {
                // TODO: This needs to be fixed
                if (validPizzaUpdate) {
                  tempPizzaSize = size;
                } else {
                  selectedSize = size!;
                  // update state
                  await db
                      .collection('state')
                      .doc('1')
                      .update({'pizzaValues.size': size.label});
                }
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
          // pizza sauce dropdown
          DropdownMenu<PizzaSauce>(
            key: const Key('pizzaSauceDropdown'),
            initialSelection: selectedSauce,
            label: const Text('Pizza Sauce'),
            onSelected: (PizzaSauce? sauce) {
              setState(() async {
                if (validPizzaUpdate) {
                  tempPizzaSauce = sauce!;
                } else {
                  selectedSauce = sauce!;

                  // update state
                  await db
                      .collection('state')
                      .doc('1')
                      .update({'pizzaValues.sauce': sauce.label});
                }
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
          // pizza crust dropdown
          DropdownMenu<PizzaCrust>(
            key: const Key('pizzaCrustDropdown'),
            initialSelection: selectedCrust,
            label: const Text('Pizza Crust'),
            onSelected: (PizzaCrust? crust) {
              setState(() async {
                if (validPizzaUpdate) {
                  tempPizzaCrust = crust!;
                } else {
                  selectedCrust = crust!;

                  // update state
                  await db
                      .collection('state')
                      .doc('1')
                      .update({'pizzaValues.crust': crust.label});
                }
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
                  onChanged: (bool? value) {
                    // do not do async stuff in setState
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
                      if (!validPizzaUpdate) {
                        db.collection('state').doc('1').update({
                          'pizzaValues.toppings':
                              FieldValue.arrayUnion([toppings[index]])
                        });
                      }
                    } else {
                      if (!validPizzaUpdate) {
                        db.collection('state').doc('1').update({
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
                  // get the current time
                  final now = DateTime.now().millisecondsSinceEpoch;

                  // sort the list to make it easier to compare later
                  if (validPizzaUpdate) {
                    selectedToppings = (tempSelectedToppings!..sort()).toList();
                  } else {
                    selectedToppings = (selectedToppings..sort()).toList();
                  }

                  // only instantiate if a pizza is being created
                  Pizza pizza;
                  int numberOfPizzas;

                  // these are needed for both update and creation, since we
                  // have to check for an identical pizza in the database
                  CollectionReference cart = db.collection('cart');
                  QuerySnapshot snapshot = await cart.get();

                  bool validPizzaId = pizzaId != null && pizzaId!.isNotEmpty;

                  // create the pizza object
                  if (!validPizzaUpdate) {
                    pizza = Pizza(
                      pizzaSize: selectedSize,
                      toppings: selectedToppings,
                      sauce: selectedSauce,
                      crustType: selectedCrust,
                      timestamp: now,
                    );

                    // get number of pizzas in the cart
                    numberOfPizzas = snapshot.docs.length;

                    // if the order is full
                    if (numberOfPizzas >= 5) {
                      if (context.mounted) {
                        showSnackBar(context,
                            'You have reached the limit of pizzas. Please remove one before creating another one.');
                      } else {
                        logger.d('Context not mounted');
                        return;
                      }
                      return;
                    }
                  } else {
                    if (validPizzaId) {
                      pizza = Pizza.withId(
                        pizzaSize: tempPizzaSize!,
                        toppings: tempSelectedToppings!,
                        sauce: tempPizzaSauce!,
                        crustType: tempPizzaCrust!,
                        timestamp: now,
                        id: pizzaId!,
                      );
                    } else {
                      logger.d('Invalid Pizza ID.');
                      return;
                    }
                  }

                  // check if an identical pizza already exists in the database
                  for (var doc in snapshot.docs) {
                    final recordPizzaSize = doc.get('size') as String;
                    final recordSauce = doc.get('sauce') as String;
                    final recordCrust = doc.get('crust') as String;

                    // list manipulation for comparison
                    dynamic recordToppings =
                        doc.get('toppings') as List<dynamic>;
                    recordToppings = List<String>.from(recordToppings);
                    recordToppings = (recordToppings..sort()).toList();

                    bool identicalPizzaAlreadyExists;

                    if (validPizzaUpdate) {
                      identicalPizzaAlreadyExists =
                          pizza.pizzaSize.label == recordPizzaSize &&
                              pizza.sauce.label == recordSauce &&
                              pizza.crustType.label == recordCrust &&
                              const ListEquality()
                                  .equals(recordToppings, pizza.toppings);
                    } else {
                      identicalPizzaAlreadyExists =
                          pizza.pizzaSize.label == recordPizzaSize &&
                              pizza.sauce.label == recordSauce &&
                              pizza.crustType.label == recordCrust &&
                              const ListEquality()
                                  .equals(recordToppings, pizza.toppings);
                    }

                    if (identicalPizzaAlreadyExists) {
                      // tell user that there's already an identical pizza in the cart
                      if (context.mounted) {
                        // a snackbar won't show over the modal bottom sheet, so we'll
                        // show a dialog if the modal bottom sheet is up
                        if (validPizzaUpdate) {
                          showIdenticalPizzaDialog(context);
                        } else {
                          showSnackBar(context,
                              'An identical pizza is already in your cart. Please make this one unique before proceeding.');
                        }
                      } else {
                        logger.d('Context not mounted');
                        return;
                      }

                      return;
                    }
                  }

                  if (validPizzaUpdate && !validPizzaId) {
                    if (context.mounted) {
                      showSnackBar(context, 'Pizza ID is invalid.');
                      logger.d('Pizza ID is invalid');
                      return;
                    } else {
                      logger.d('Context not mounted.');
                      return;
                    }
                  }

                  try {
                    await db
                        .collection('cart')
                        .doc(pizza.id)
                        .set(pizza.toMap());

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

                  // TODO: This is not navigating and showing the snackbar correctly
                  if (context.mounted) {
                    if (validPizzaUpdate) {
                      Navigator.of(context).pop(true);
                    } else {
                      Navigator.of(context).pop(false);
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
                    key: const Key('deleteButton'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () {
                      showDeletePizzaDialog(context, db);
                    },
                    child: const Text('Delete Pizza')),
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
            title: const Text('No Changes Made'),
            content: const Text(
                "Make changes, or if you like your pizza how it is, press 'Cancel'."),
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
