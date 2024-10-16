import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_chef/screens/home.dart';
import 'package:pizza_chef/bloc/small_pizza/small_pizza_bloc.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SmallPizzaCounterBloc(),
        )
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        
        home: Home(),
      ),
    ),
  );
}
