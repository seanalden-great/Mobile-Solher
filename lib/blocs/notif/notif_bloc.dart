import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/notif_repository.dart';
import 'notif_event.dart';
import 'notif_state.dart';

class NotifBloc extends Bloc<NotifEvent, NotifState> {
  final NotifRepository notifRepository;

  NotifBloc({required this.notifRepository}) : super(NotifInitial()) {
    on<FetchNotifsEvent>((event, emit) async {
      emit(NotifLoading());
      try {
        final notifs = await notifRepository.fetchNotifications();
        emit(NotifLoaded(notifs));
      } catch (e) {
        emit(NotifError(e.toString()));
      }
    });

    on<MarkNotifAsReadEvent>((event, emit) async {
      try {
        await notifRepository.markAsRead(event.id);
        add(FetchNotifsEvent());
      } catch (e) {
        emit(NotifError(e.toString()));
      }
    });

    on<MarkAllNotifsAsReadEvent>((event, emit) async {
      try {
        await notifRepository.markAllAsRead();
        add(FetchNotifsEvent());
      } catch (e) {
        emit(NotifError(e.toString()));
      }
    });
  }
}
