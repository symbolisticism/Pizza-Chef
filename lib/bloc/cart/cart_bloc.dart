import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState([])) {
    on<AddToCart>((event, emit) {});
    on<RemoveFromCart>((event, emit) {});
    on<UpdateInCart>((event, emit) {});
  }
}
