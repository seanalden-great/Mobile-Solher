import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact_model.dart';

class ContactRepository {
  final Dio _dio = Dio();
  final String baseUrl = 'https://back.solher.co.id/api';

  // Fungsi internal untuk mengambil token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 👇 FUNGSI 1: Mengirim Form Kontak 👇
  Future<String> submitContactForm({
    required String name,
    required String email,
    required String phone,
    required String description,
  }) async {
    try {
      final token = await _getToken();

      // Jika user login, kirim token. Jika guest, kirim tanpa token.
      final headers = token != null && token.isNotEmpty
          ? {'Authorization': 'Bearer $token', 'Accept': 'application/json'}
          : {'Accept': 'application/json'};

      final response = await _dio.post(
        '$baseUrl/contact',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'description': description,
        },
        options: Options(headers: headers),
      );

      return response.data['message'] ?? 'Pesan berhasil dikirim!';
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal mengirim pesan. Coba lagi.');
    } catch (e) {
      throw Exception('Terjadi kesalahan sistem.');
    }
  }

  // 👇 FUNGSI 2: Mengambil Riwayat Pesan (Hanya untuk User Login) 👇
  Future<List<ContactModel>> fetchContactHistory() async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Silakan login terlebih dahulu.');
      }

      final response = await _dio.get(
        '$baseUrl/user/contact-history',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      // Konversi data JSON menjadi List of ContactModel
      List<ContactModel> histories =
          (response.data as List).map((i) => ContactModel.fromJson(i)).toList();

      return histories;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat riwayat.');
    } catch (e) {
      throw Exception('Terjadi kesalahan sistem.');
    }
  }
}
