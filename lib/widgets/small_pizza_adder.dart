import 'package:flutter/material.dart';
import 'package:pizza_chef/bloc/small_pizza/small_pizza_bloc.dart';
import 'package:pizza_chef/bloc/small_pizza/small_pizza_state.dart';
import 'package:pizza_chef/bloc/small_pizza/small_pizza_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

class SmallPizzaAdder extends StatelessWidget {
  const SmallPizzaAdder({
    super.key,
    required this.textEditingController,
    required this.counterBloc,
  });

  final TextEditingController textEditingController;
  final SmallPizzaCounterBloc counterBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmallPizzaCounterBloc, SmallPizzaCounterState>(
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          textEditingController.text = state.count.toString();
        });

        return Row(
          children: [
            IconButton(
              onPressed: () {
                counterBloc.add(SmallPizzaDecrement()); // add an event
              },
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: TextFormField(
                controller: textEditingController,
                decoration: const InputDecoration(
                    label: Text('How many small pizzas?')),
              ),
            ),
            IconButton(
              onPressed: () {
                counterBloc.add(SmallPizzaIncrement()); // add an event
              },
              icon: const Icon(Icons.add),
            ),
          ],
        );
      },
    );
  }
}
