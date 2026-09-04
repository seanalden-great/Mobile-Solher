// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:solher_mobile/models/user_model.dart';

// class AuthRepository {
//   final Dio _dio = Dio();
//   final String baseUrl = 'https://back.solher.co.id/api';

//   // --- LOGIN ---
//   Future<Map<String, dynamic>> login(
//       String email, String password, String appSecret) async {
//     try {
//       // 👇 PERBAIKAN: Tembak ke endpoint khusus mobile 👇
//       final response = await _dio.post('$baseUrl/mobile/login', data: {
//         'email': email,
//         'password': password,
//         'app_secret': appSecret, // 👈 PERBAIKAN: Gunakan app_secret
//       });

//       return {
//         'token': response.data['access_token'],
//         'user': UserModel.fromJson(response.data['user']),
//         'user_json': json.encode(response.data['user']),
//       };
//     } on DioException catch (e) {
//       final errorMessage =
//           e.response?.data['message'] ?? 'Gagal menghubungi server.';
//       throw Exception(errorMessage);
//     }
//   }

//   // --- REGISTER ---
//   Future<void> register(
//       String firstName, String lastName, String email, String password) async {
//     try {
//       await _dio.post('$baseUrl/register', data: {
//         'first_name': firstName,
//         'last_name': lastName,
//         'email': email,
//         'password': password,
//       });
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 422) {
//         final errors = e.response?.data as Map<String, dynamic>;
//         final firstError = errors.values.first[0];
//         throw Exception(firstError);
//       }
//       throw Exception(e.response?.data['message'] ?? 'Pendaftaran gagal.');
//     }
//   }

//   // --- FORGOT PASSWORD (KIRIM OTP) ---
//   Future<void> sendResetCode(String email) async {
//     try {
//       await _dio
//           .post('$baseUrl/forgot-password/send-code', data: {'email': email});
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['message'] ?? 'Gagal mengirim OTP.');
//     }
//   }

//   // --- FORGOT PASSWORD (VERIFIKASI OTP) ---
//   Future<void> verifyResetCode(String email, String code) async {
//     try {
//       await _dio.post('$baseUrl/forgot-password/verify-code', data: {
//         'email': email,
//         'code': code,
//       });
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['message'] ?? 'Kode verifikasi salah.');
//     }
//   }

//   // --- FORGOT PASSWORD (UBAH PASSWORD BARU) ---
//   Future<void> resetPassword(String email, String code, String password,
//       String confirmPassword) async {
//     try {
//       await _dio.post('$baseUrl/forgot-password/reset', data: {
//         'email': email,
//         'code': code,
//         'password': password,
//         'password_confirmation': confirmPassword,
//       });
//     } on DioException catch (e) {
//       throw Exception(
//           e.response?.data['message'] ?? 'Gagal mengubah password.');
//     }
//   }

//   // --- UPDATE PROFIL ---
//   Future<Map<String, dynamic>> updateProfileInfo(
//       String firstName, String lastName, String email, String phone) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       final response = await _dio.post(
//         '$baseUrl/user/update-info',
//         data: {
//           'first_name': firstName,
//           'last_name': lastName,
//           'email': email,
//           'phone': phone
//         },
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );

//       final updatedUser = UserModel.fromJson(response.data['user']);
//       await prefs.setString('user_data', json.encode(response.data['user']));
//       return {'user': updatedUser, 'message': response.data['message']};
//     } on DioException catch (e) {
//       throw Exception(
//           e.response?.data['message'] ?? 'Gagal memperbarui profil.');
//     }
//   }

//   // --- UPDATE FOTO PROFIL ---
//   Future<Map<String, dynamic>> updateProfileImage(String filePath) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       final formData = FormData.fromMap({
//         'image': await MultipartFile.fromFile(filePath),
//       });

//       final response = await _dio.post(
//         '$baseUrl/user/update-image',
//         data: formData,
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );

//       final updatedUser = UserModel.fromJson(response.data['user']);
//       await prefs.setString('user_data', json.encode(response.data['user']));
//       return {'user': updatedUser, 'message': response.data['message']};
//     } on DioException catch (e) {
//       throw Exception(
//           e.response?.data['message'] ?? 'Gagal mengunggah foto profil.');
//     }
//   }
// }

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solher_mobile/models/user_model.dart';

class AuthRepository {
  final Dio _dio = Dio();
  final String baseUrl = 'https://back.solher.co.id/api';

  // 👇 [BARU] Helper cerdas untuk mengekstrak pesan error dengan aman 👇
  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
      return e.response?.data['message'] ?? 'Terjadi kesalahan pada server.';
    }
    // Jika server memuntahkan HTML atau String murni (Error 500/404)
    return 'Gagal menghubungi server (Error ${e.response?.statusCode ?? 'Unknown'}).';
  }

  // --- LOGIN ---
  Future<Map<String, dynamic>> login(
      String email, String password, String appSecret) async {
    try {
      final response = await _dio.post('$baseUrl/mobile/login', data: {
        'email': email,
        'password': password,
        'app_secret': appSecret,
      });

      return {
        'token': response.data['access_token'],
        'user': UserModel.fromJson(response.data['user']),
        'user_json': json.encode(response.data['user']),
      };
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
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
      if (e.response?.statusCode == 422 && e.response?.data is Map) {
        final errors = e.response?.data as Map<String, dynamic>;
        final firstError = errors.values.first[0];
        throw Exception(firstError);
      }
      throw Exception(_extractErrorMessage(e));
    }
  }

  // --- FORGOT PASSWORD (KIRIM OTP) ---
  Future<void> sendResetCode(String email) async {
    try {
      await _dio
          .post('$baseUrl/forgot-password/send-code', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
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
      throw Exception(_extractErrorMessage(e));
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
      throw Exception(_extractErrorMessage(e));
    }
  }

  // --- UPDATE PROFIL ---
  Future<Map<String, dynamic>> updateProfileInfo(
      String firstName, String lastName, String email, String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await _dio.post(
        '$baseUrl/user/update-info',
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
      throw Exception(_extractErrorMessage(e));
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
        '$baseUrl/user/update-image',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final updatedUser = UserModel.fromJson(response.data['user']);
      await prefs.setString('user_data', json.encode(response.data['user']));
      return {'user': updatedUser, 'message': response.data['message']};
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }
}
