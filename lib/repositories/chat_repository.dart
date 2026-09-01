import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';

class ChatRepository {
  final Dio _dio = Dio();
  final String baseUrl = 'https://back.solher.co.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fungsi khusus untuk mendapatkan ID pengguna yang sedang login
  Future<int> getMyId() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user_data');
    if (userStr != null) {
      return json.decode(userStr)['id'] ?? 0;
    }
    return 0;
  }

  Future<List<ChatAdminModel>> fetchChatAdmins() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$baseUrl/chat/admins',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return (response.data as List)
          .map((i) => ChatAdminModel.fromJson(i))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar admin.');
    }
  }

  Future<List<ChatMessageModel>> fetchChatMessages(int receiverId) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$baseUrl/chat/messages/$receiverId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return (response.data as List)
          .map((i) => ChatMessageModel.fromJson(i))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat pesan.');
    }
  }

  Future<void> sendChatMessage({
    required int receiverId,
    required String message,
  }) async {
    try {
      final token = await _getToken();
      await _dio.post(
        '$baseUrl/chat/send',
        data: {'receiver_id': receiverId, 'message': message},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Gagal mengirim pesan.');
    }
  }

  Future<void> markMessagesRead(int senderId) async {
    try {
      final token = await _getToken();
      await _dio.post(
        '$baseUrl/chat/read/$senderId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      // Dibiarkan kosong karena hanya berjalan diam-diam di background
    }
  }
}
