abstract class ChatEvent {}

class FetchChatAdmins extends ChatEvent {}

class FetchChatMessages extends ChatEvent {
  final int receiverId;
  FetchChatMessages(this.receiverId);
}

class SendChatMessage extends ChatEvent {
  final int receiverId;
  final String message;
  SendChatMessage({required this.receiverId, required this.message});
}

class MarkMessagesRead extends ChatEvent {
  final int senderId;
  MarkMessagesRead(this.senderId);
}

class AddLocalMessage extends ChatEvent {
  final dynamic message;
  AddLocalMessage(this.message);
}
