import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/checkout_repository.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CheckoutRepository repository;

  CheckoutBloc({required this.repository}) : super(CheckoutInitial()) {
    on<SubmitCheckoutEvent>((event, emit) async {
      emit(CheckoutLoading());
      try {
        final url = await repository.submitCheckout(event.payload);
        emit(CheckoutSuccess(url));
      } catch (e) {
        emit(CheckoutError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
