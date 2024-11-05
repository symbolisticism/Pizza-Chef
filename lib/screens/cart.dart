import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:pizza_chef/data/pizza_crust.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:pizza_chef/models/pizza.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: FutureBuilder(
          future: loadPizzas(),
          builder: (context, snapshot) {
            // content is always null
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                logger.e(snapshot.error);
                return Center(child: Text("${snapshot.error} has occurred."));
              } else if (snapshot.hasData &&
                  content != null &&
                  pizzas.isEmpty) {
                return const Center(
                    child: Text("There are no pizzas to display."));
              } else if (snapshot.hasData &&
                  content != null &&
                  pizzas.isNotEmpty) {
                return content!;
              } else if (content == null) {
                return const Center(child: Text('Content is null.'));
              } else {
                return const Center(
                    child: Text('An unexpected error has occurred.'));
              }
            }

            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  Future<Widget> loadPizzas() async {
    final QuerySnapshot querySnapshot = await db.collection('cart').get();

    for (var doc in querySnapshot.docs) {
      final pizzaId = doc.id;
      dynamic pizzaSize = doc.get('pizzaSize') as String;
      final toppingsDynamic = doc.get('toppings') as List<dynamic>;
      dynamic sauce = doc.get('sauce') as String;
      dynamic crust = doc.get('thinCrust') as String;
      dynamic timestamp = doc.get('timestamp') as Timestamp;

      List<String> toppings = List<String>.from(toppingsDynamic);

      // reassign as the right type
      switch (pizzaSize) {
        case 'Small':
          pizzaSize = PizzaSize.small;
          break;
        case 'Medium':
          pizzaSize = PizzaSize.medium;
          break;
        case 'Large':
          pizzaSize = PizzaSize.large;
          break;
      }

      // reassign as the right type
      switch (sauce) {
        case 'Red':
          sauce = PizzaSauce.red;
          break;
        case 'White':
          sauce = PizzaSauce.white;
          break;
      }

      // reassign as the right type
      switch (crust) {
        case 'Thin Crust':
          crust = PizzaCrust.thinCrust;
          break;
        case 'Regular Crust':
          crust = PizzaCrust.regularCrust;
          break;
      }

      timestamp = timestamp.toDate();

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


    return content = Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: pizzas.length,
        itemBuilder: (context, index) {
          List<String> keys = pizzas.keys.toList();
          List<Pizza> values = pizzas.values.toList();

          String key = keys[index];
          Pizza value = values[index];

          return ListTile(
            // title: Text(key),
            title: Text(value.toString()),
            leading: const Icon(Icons.done, color: Colors.green),
            trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
          );
        },
      ),
    );
  }
}
