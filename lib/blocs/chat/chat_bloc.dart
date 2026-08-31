// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../models/chat_model.dart';
// import 'chat_event.dart';
// import 'chat_state.dart';

// class ChatBloc extends Bloc<ChatEvent, ChatState> {
//   final Dio _dio = Dio(BaseOptions(baseUrl: 'https://back.solher.co.id/api'));

//   ChatBloc() : super(ChatInitial()) {
//     on<FetchChatAdmins>((event, emit) async {
//       emit(ChatLoading());
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final token = prefs.getString('token');
//         final response = await _dio.get('/chat/admins',
//             options: Options(headers: {'Authorization': 'Bearer $token'}));

//         List<ChatAdminModel> admins = (response.data as List)
//             .map((i) => ChatAdminModel.fromJson(i))
//             .toList();
//         emit(ChatAdminsLoaded(admins));
//       } catch (e) {
//         emit(ChatError('Gagal memuat daftar admin.'));
//       }
//     });

//     on<FetchChatMessages>((event, emit) async {
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final token = prefs.getString('token');
//         final response = await _dio.get('/chat/messages/${event.receiverId}',
//             options: Options(headers: {'Authorization': 'Bearer $token'}));

//         List<ChatMessageModel> messages = (response.data as List)
//             .map((i) => ChatMessageModel.fromJson(i))
//             .toList();

//         emit(ChatMessagesLoaded(messages));
//       } catch (e) {
//         emit(ChatError('Gagal memuat pesan.'));
//       }
//     });

//     on<SendChatMessage>((event, emit) async {
//       if (state is ChatMessagesLoaded) {
//         final currentState = state as ChatMessagesLoaded;
//         emit(ChatMessagesLoaded(currentState.messages, isAiThinking: true));

//         try {
//           final prefs = await SharedPreferences.getInstance();
//           final token = prefs.getString('token');
//           await _dio.post('/chat/send',
//               data: {'receiver_id': event.receiverId, 'message': event.message},
//               options: Options(headers: {'Authorization': 'Bearer $token'}));

//           // Panggil ulang pesan untuk mendapatkan balasan AI
//           add(FetchChatMessages(event.receiverId));
//         } catch (e) {
//           emit(ChatMessagesLoaded(currentState.messages, isAiThinking: false));
//         }
//       }
//     });

//     on<MarkMessagesRead>((event, emit) async {
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final token = prefs.getString('token');
//         await _dio.post('/chat/read/${event.senderId}',
//             options: Options(headers: {'Authorization': 'Bearer $token'}));
//       } catch (e) {}
//     });
//   }
// }

import 'dart:convert';
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

        // Ambil ID User untuk validasi pengirim
        final userStr = prefs.getString('user_data');
        int myId = 0;
        if (userStr != null) {
          myId = json.decode(userStr)['id'];
        }

        final response = await _dio.get('/chat/messages/${event.receiverId}',
            options: Options(headers: {'Authorization': 'Bearer $token'}));

        List<ChatMessageModel> messages = (response.data as List)
            .map((i) => ChatMessageModel.fromJson(i))
            .toList();

        bool thinking = false;

        if (state is ChatMessagesLoaded) {
          final currentState = state as ChatMessagesLoaded;
          thinking = currentState.isAiThinking;

          // 👇 PELINDUNG OPTIMISTIC UI 👇
          // Jika jumlah pesan dari API lebih sedikit dari state layar saat ini,
          // artinya pesan instan kita belum selesai diproses oleh database.
          // Kita abaikan respons API yang terlambat ini agar pesan instan tidak lenyap.
          if (messages.length < currentState.messages.length) {
            messages = currentState.messages;
          } else {
            // 👇 PELINDUNG ANIMASI AI 👇
            // Jika status sedang 'thinking', cek pesan paling terakhir.
            if (thinking && messages.isNotEmpty) {
              final latestMsg = messages.last;
              // Animasi HANYA akan dimatikan jika pesan terakhir berasal dari AI/Admin (Bukan dari User)
              if (latestMsg.senderId != myId) {
                thinking = false;
              }
            }
          }
        }

        emit(ChatMessagesLoaded(messages, isAiThinking: thinking));
      } catch (e) {
        emit(ChatError('Gagal memuat pesan.'));
      }
    });

    on<SendChatMessage>((event, emit) async {
      if (state is ChatMessagesLoaded) {
        final currentState = state as ChatMessagesLoaded;

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final userStr = prefs.getString('user_data');
        int myId = 0;
        if (userStr != null) {
          myId = json.decode(userStr)['id'];
        }

        // 🚀 1. IMPLEMENTASI OPTIMISTIC UI 🚀
        // Buat objek pesan bayangan secara lokal tanpa ID server
        final tempMessage = ChatMessageModel.fromJson({
          'id': DateTime.now().millisecondsSinceEpoch,
          'sender_id': myId,
          'receiver_id': event.receiverId,
          'message': event.message,
          'created_at': DateTime.now().toIso8601String(),
          'sender': null,
        });

        // Tambahkan pesan bayangan ke daftar pesan saat ini
        final optimisticMessages =
            List<ChatMessageModel>.from(currentState.messages)
              ..add(tempMessage);

        // 🚀 Tampilkan pesan ke layar SEETIKA ITU JUGA dan nyalakan animasi AI
        emit(ChatMessagesLoaded(optimisticMessages, isAiThinking: true));

        try {
          // 2. Lakukan pengiriman data ke server secara diam-diam (Background)
          await _dio.post('/chat/send',
              data: {'receiver_id': event.receiverId, 'message': event.message},
              options: Options(headers: {'Authorization': 'Bearer $token'}));

          // 3. Setelah sukses dikirim, tarik pembaruan data secara natural
          // Animasi "AI Thinking" akan dipertahankan oleh FetchChatMessages sampai AI benar-benar membalas
          add(FetchChatMessages(event.receiverId));
        } catch (e) {
          // ❌ 4. ROLLBACK (BATALKAN) JIKA GAGAL ❌
          // Jika API gagal (no internet/server down), kembalikan layar ke daftar pesan asli
          // sebelum user mengetik, dan matikan animasinya.
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
