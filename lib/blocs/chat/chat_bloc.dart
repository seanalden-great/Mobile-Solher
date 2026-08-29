import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/chat_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://back.solher.co.id/api'));

  ChatBloc() : super(ChatInitial()) {
    on<FetchChatAdmins>((event, emit) async {
      emit(ChatLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final response = await _dio.get('/chat/admins',
            options: Options(headers: {'Authorization': 'Bearer $token'}));

        List<ChatAdminModel> admins = (response.data as List)
            .map((i) => ChatAdminModel.fromJson(i))
            .toList();
        emit(ChatAdminsLoaded(admins));
      } catch (e) {
        emit(ChatError('Gagal memuat daftar admin.'));
      }
    });

    on<FetchChatMessages>((event, emit) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final response = await _dio.get('/chat/messages/${event.receiverId}',
            options: Options(headers: {'Authorization': 'Bearer $token'}));

        List<ChatMessageModel> messages = (response.data as List)
            .map((i) => ChatMessageModel.fromJson(i))
            .toList();

        emit(ChatMessagesLoaded(messages));
      } catch (e) {
        emit(ChatError('Gagal memuat pesan.'));
      }
    });

    on<SendChatMessage>((event, emit) async {
      if (state is ChatMessagesLoaded) {
        final currentState = state as ChatMessagesLoaded;
        emit(ChatMessagesLoaded(currentState.messages, isAiThinking: true));

        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          await _dio.post('/chat/send',
              data: {'receiver_id': event.receiverId, 'message': event.message},
              options: Options(headers: {'Authorization': 'Bearer $token'}));

          // Panggil ulang pesan untuk mendapatkan balasan AI
          add(FetchChatMessages(event.receiverId));
        } catch (e) {
          emit(ChatMessagesLoaded(currentState.messages, isAiThinking: false));
        }
      }
    });

    on<MarkMessagesRead>((event, emit) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        await _dio.post('/chat/read/${event.senderId}',
            options: Options(headers: {'Authorization': 'Bearer $token'}));
      } catch (e) {}
    });
  }
}
