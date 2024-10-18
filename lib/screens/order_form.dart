import 'package:flutter/material.dart';
import 'package:pizza_chef/bloc/small_pizza/small_pizza_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_chef/bloc/small_pizza/small_pizza_event.dart';
import 'package:pizza_chef/bloc/small_pizza/small_pizza_state.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

class OrderForm extends StatefulWidget {
  const OrderForm({super.key});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final _formKey = GlobalKey<FormState>();
  final smallPizzaController = TextEditingController();
  bool secondSection = false;

  @override
  void dispose() {
    smallPizzaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final smallPizzaCounterBloc = context.read<SmallPizzaCounterBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Order'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Row(children: [Text('How many pizzas would you like?')]),
              BlocBuilder<SmallPizzaCounterBloc, SmallPizzaCounterState>(
                builder: (context, state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    smallPizzaController.text = state.count.toString();
                    logger.d(state.count);
                  });

                  return Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          smallPizzaCounterBloc
                              .add(SmallPizzaDecrement()); // add an event
                        },
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
                        onPressed: () {
                          smallPizzaCounterBloc
                              .add(SmallPizzaIncrement()); // add an event
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  );
                },
              ),
              TextButton(
                onPressed: () {
                  secondSection = true;
                },
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
