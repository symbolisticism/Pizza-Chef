import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:pizza_chef/models/pizza.dart';
import 'package:pizza_chef/widgets/order_form_widget.dart';

final db = FirebaseFirestore.instance;
var logger = Logger(printer: PrettyPrinter());

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  Widget? content;
  Map<String, Pizza> pizzas = {};
  late Future<void> pizzasFuture;

  @override
  void initState() {
    super.initState();
    pizzasFuture = loadPizzas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              return const Center(child: Text("There are no pizzas to display."));
            } else {
              return content!;
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> loadPizzas() async {
    pizzas.clear();
    final QuerySnapshot querySnapshot = await db.collection('cart').get();

    for (var doc in querySnapshot.docs) {
      final pizzaId = doc.id;
      dynamic pizzaSize = doc.get('pizzaSize') as String;
      final toppingsDynamic = doc.get('toppings') as List<dynamic>;
      dynamic sauce = doc.get('sauce') as String;
      dynamic crust = doc.get('thinCrust') as String;
      dynamic timestamp = doc.get('timestamp') as Timestamp;

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
      timestamp = timestamp.toDate();

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
}