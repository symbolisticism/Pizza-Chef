import 'package:flutter/material.dart';
import 'package:pizza_chef/data/pizza_sauce.dart';
import 'package:pizza_chef/data/pizza_size.dart';
import 'package:pizza_chef/data/pizza_crust.dart';

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
  PizzaSize? selectedSize;
  PizzaSauce? selectedSauce;
  PizzaCrust? selectedCrust;

  @override
  void dispose() {
    sizeController.dispose();
    sauceController.dispose();
    crustController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order'),
      ),
      body: Form(
        key: _formKey,
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
                    selectedSize = size;
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
                    selectedSauce = sauce;
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
                    selectedCrust = crust;
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
            ],
          ),
        ),
      ),
    );
  }
}
