import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_chef/bloc/small_pizza/small_pizza_event.dart';
import 'package:pizza_chef/bloc/small_pizza/small_pizza_state.dart';

class SmallPizzaCounterBloc
    extends Bloc<SmallPizzaCounterEvent, SmallPizzaCounterState> {
  SmallPizzaCounterBloc() : super(SmallPizzaCounterState(0)) {
    on<SmallPizzaIncrement>((event, emit) {
      emit(SmallPizzaCounterState(state.count + 1)); // increment the counter
    });
    on<SmallPizzaDecrement>((event, emit) {
      emit(SmallPizzaCounterState(state.count - 1)); // decrement the counter
    });
  }
}
