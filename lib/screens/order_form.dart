import 'package:flutter/material.dart';

class OrderForm extends StatefulWidget {
  const OrderForm({super.key});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final _formKey = GlobalKey<FormState>();
  final largePizzaController = TextEditingController();
  final mediumPizzaController = TextEditingController();
  final smallPizzaController = TextEditingController();

  @override
  void dispose() {
    largePizzaController.dispose();
    mediumPizzaController.dispose();
    smallPizzaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Order'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const Row(
              children: [Text('How many pizzas would you like?')],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: TextFormField(
                    controller: largePizzaController,
                    decoration: const InputDecoration(
                        label: Text('How many large pizzas?')),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: TextFormField(
                    controller: mediumPizzaController,
                    decoration: const InputDecoration(
                        label: Text('How many medium pizzas?')),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: TextFormField(
                    controller: smallPizzaController,
                    decoration: const InputDecoration(
                        label: Text('How many small pizzas?')),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
