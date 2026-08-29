import '../../models/chat_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatAdminsLoaded extends ChatState {
  final List<ChatAdminModel> admins;
  ChatAdminsLoaded(this.admins);
}

class ChatMessagesLoaded extends ChatState {
  final List<ChatMessageModel> messages;
  final bool isAiThinking;
  ChatMessagesLoaded(this.messages, {this.isAiThinking = false});
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
