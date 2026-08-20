import 'package:dio/dio.dart';
import '../models/event_model.dart';

class EventRepository {
  final Dio _dio = Dio();
  final String baseUrl = 'https://back.solher.co.id/api';

  Future<List<EventModel>> fetchEvents() async {
    try {
      final response = await _dio.get(
        '$baseUrl/events',
        // Opsional: Anda bisa mengirim header Accept-Language seperti di Vue jika ada sistem i18n
        options: Options(headers: {'Accept-Language': 'id'}),
      );
      final data = response.data as List;
      return data.map((e) => EventModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data event: $e');
    }
  }
}