abstract class NotifEvent {}

class FetchNotifsEvent extends NotifEvent {}

class MarkNotifAsReadEvent extends NotifEvent {
  final int id;
  MarkNotifAsReadEvent(this.id);
}

class MarkAllNotifsAsReadEvent extends NotifEvent {}
