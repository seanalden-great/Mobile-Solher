import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotifRepository {
  final String baseUrl = 'https://back.solher.co.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    final token = await _getToken();
    if (token == null) throw Exception('Unauthorized');

    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat notifikasi');
    }
  }

  Future<void> markAsRead(int id) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode != 200) throw Exception('Gagal menandai dibaca');
  }

  Future<void> markAllAsRead() async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/mark-all-read'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode != 200)
      throw Exception('Gagal menandai semua dibaca');
  }
}
