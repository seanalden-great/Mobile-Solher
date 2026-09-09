import '../../models/notification_model.dart';

abstract class NotifState {}

class NotifInitial extends NotifState {}

class NotifLoading extends NotifState {}

class NotifLoaded extends NotifState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotifLoaded(this.notifications)
      : unreadCount = notifications.where((n) => !n.isRead).length;
}

class NotifError extends NotifState {
  final String message;
  NotifError(this.message);
}
