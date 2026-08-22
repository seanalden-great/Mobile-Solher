import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solher_mobile/models/user_model.dart';

class AuthRepository {
  final Dio _dio = Dio();
  final String baseUrl = 'https://back.solher.co.id/api';

  // --- LOGIN ---
  Future<Map<String, dynamic>> login(
      String email, String password, String captchaToken) async {
    try {
      final response = await _dio.post('$baseUrl/login', data: {
        'email': email,
        'password': password,
        'captcha_token': captchaToken, // Diwajibkan oleh backend Laravel Anda
      });

      return {
        'token': response.data['access_token'],
        'user': UserModel.fromJson(response.data['user']),
        'user_json': json.encode(response.data['user']),
      };
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Gagal menghubungi server.';
      throw Exception(errorMessage);
    }
  }

  // --- REGISTER ---
  Future<void> register(
      String firstName, String lastName, String email, String password) async {
    try {
      await _dio.post('$baseUrl/register', data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
      });
    } on DioException catch (e) {
      // Menangkap error validasi 422 dari Laravel (contoh: email sudah dipakai)
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data as Map<String, dynamic>;
        final firstError = errors.values.first[0]; // Ambil pesan error pertama
        throw Exception(firstError);
      }
      throw Exception(e.response?.data['message'] ?? 'Pendaftaran gagal.');
    }
  }

  // --- FORGOT PASSWORD (KIRIM OTP) ---
  Future<void> sendResetCode(String email) async {
    try {
      await _dio
          .post('$baseUrl/forgot-password/send-code', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengirim OTP.');
    }
  }

  // --- FORGOT PASSWORD (VERIFIKASI OTP) ---
  Future<void> verifyResetCode(String email, String code) async {
    try {
      await _dio.post('$baseUrl/forgot-password/verify-code', data: {
        'email': email,
        'code': code,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Kode verifikasi salah.');
    }
  }

  // --- FORGOT PASSWORD (UBAH PASSWORD BARU) ---
  Future<void> resetPassword(String email, String code, String password,
      String confirmPassword) async {
    try {
      await _dio.post('$baseUrl/forgot-password/reset', data: {
        'email': email,
        'code': code,
        'password': password,
        'password_confirmation': confirmPassword,
      });
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal mengubah password.');
    }
  }

  // --- UPDATE PROFIL ---
  Future<Map<String, dynamic>> updateProfileInfo(
      String firstName, String lastName, String email, String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await _dio.post(
        '$baseUrl/user/update-info', // Sesuaikan endpoint Laravel Anda
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final updatedUser = UserModel.fromJson(response.data['user']);
      await prefs.setString('user_data', json.encode(response.data['user']));
      return {'user': updatedUser, 'message': response.data['message']};
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal memperbarui profil.');
    }
  }

  // --- UPDATE FOTO PROFIL ---
  Future<Map<String, dynamic>> updateProfileImage(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        '$baseUrl/user/update-image', // Sesuaikan endpoint Laravel Anda
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final updatedUser = UserModel.fromJson(response.data['user']);
      await prefs.setString('user_data', json.encode(response.data['user']));
      return {'user': updatedUser, 'message': response.data['message']};
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal mengunggah foto profil.');
    }
  }
}
