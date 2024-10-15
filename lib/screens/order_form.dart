import 'package:flutter/material.dart';

class OrderForm extends StatefulWidget {
  const OrderForm({super.key});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Order'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: const Column(
            children: [
              
            ],
          ),
        ),
      ),
    );
  }
}
