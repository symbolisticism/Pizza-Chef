import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:pizza_chef/models/pizza.dart';
import 'package:pizza_chef/widgets/nav_drawer.dart';
import 'package:pizza_chef/widgets/order_form_widget.dart';

var logger = Logger(printer: PrettyPrinter());

class Cart extends StatefulWidget {
  final FirebaseFirestore firestore;

  // make the firestore parameter optional
  Cart({super.key, FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  Widget? content;
  Map<String, Pizza> pizzas = {};
  late Future<void> pizzasFuture;
  bool stateIsUpdated = false;
  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();
    db = widget.firestore;
    pizzasFuture = loadPizzas();
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
        drawer: const NavDrawer('/cart'),
        appBar: AppBar(
          title: const Text('Cart'),
        ),
        body: FutureBuilder(
          future: pizzasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                logger.e(snapshot.error);
                return Center(child: Text("${snapshot.error} has occurred."));
              } else if (pizzas.isEmpty) {
                return const Center(
                    child: Text("There are no pizzas to display."));
              } else {
                return content!;
              }
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Future<void> loadPizzas() async {
    pizzas.clear();
    final QuerySnapshot querySnapshot = await db.collection('cart').get();

    for (var doc in querySnapshot.docs) {
      final pizzaId = doc.id;
      dynamic pizzaSize = doc.get('size') as String;
      final toppingsDynamic = doc.get('toppings') as List<dynamic>;
      dynamic sauce = doc.get('sauce') as String;
      dynamic crust = doc.get('crust') as String;
      dynamic timestamp = doc.get('timestamp') as int;

      List<String> toppings = List<String>.from(toppingsDynamic);

      // Reassign the right types
      pizzaSize = pizzaSize == 'Small'
          ? PizzaSize.small
          : pizzaSize == 'Medium'
              ? PizzaSize.medium
              : PizzaSize.large;

      sauce = sauce == 'Red' ? PizzaSauce.red : PizzaSauce.white;
      crust = crust == 'Thin Crust'
          ? PizzaCrust.thinCrust
          : PizzaCrust.regularCrust;

      // add pizzas from database into the local pizzas map
      if (!pizzas.containsKey(pizzaId)) {
        pizzas[pizzaId] = Pizza(
          pizzaSize: pizzaSize,
          toppings: toppings,
          sauce: sauce,
          crustType: crust,
          timestamp: timestamp,
        );
      }
    }

    setState(() {
      content = buildPizzasList();
    });
  }

  Widget buildPizzasList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        key: const Key('cartPizzasList'),
        itemCount: pizzas.length,
        itemBuilder: (context, index) {
          List<Pizza> values = pizzas.values.toList();
          List<String> keys = pizzas.keys.toList();

          String key = keys[index];
          Pizza value = values[index];

          return ListTile(
            title: Text(value.toString()),
            leading: const Icon(Icons.done, color: Colors.green),
            trailing: IconButton(
              onPressed: () async {
                final updateResult = await showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return FractionallySizedBox(
                      heightFactor: 0.9,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: OrderFormWidget(
                          firestore: db,
                          selectedSize: value.pizzaSize,
                          selectedSauce: value.sauce,
                          selectedCrust: value.crustType,
                          selectedToppings: value.toppings,
                          update: true,
                          id: key,
                        ),
                      ),
                    );
                  },
                );

                if (updateResult == true) {
                  // Re-load the list of pizzas after deletion or update
                  setState(() {
                    pizzasFuture = loadPizzas();
                  });
                }
              },
              icon: const Icon(Icons.edit),
            ),
          );
        },
      ),
    );
  }

  Future<void> updateState() async {
    await db.collection('state').doc('1').update({'screen': 'cart'});
  }
}
