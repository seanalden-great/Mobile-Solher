import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/affiliate_model.dart';

// Custom Exception untuk mendeteksi user yang belum menjadi Afiliator
class NotAnAffiliateException implements Exception {}

class AffiliateRepository {
  final Dio _dio = Dio();
  final String baseUrl = 'https://back.solher.co.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 👇 FUNGSI 1: Memuat Dasbor Afiliasi 👇
  Future<AffiliateDashboardModel> fetchDashboard() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$baseUrl/affiliate/dashboard',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return AffiliateDashboardModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      // Jika server merespon 403, lempar custom exception
      if (e.response?.statusCode == 403) {
        throw NotAnAffiliateException();
      }
      throw Exception(
          e.response?.data['message'] ?? 'Gagal memuat dasbor afiliasi.');
    } catch (e) {
      throw Exception('Terjadi kesalahan sistem.');
    }
  }

  // 👇 FUNGSI 2: Mendaftar Menjadi Afiliator 👇
  Future<String> applyAffiliate({
    required String socialMediaUrl,
    required String reason,
  }) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '$baseUrl/affiliate/apply',
        data: {
          'social_media_url': socialMediaUrl,
          'reason': reason,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data['message'] ?? 'Berhasil mendaftar afiliasi.';
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal mendaftar afiliasi.');
    } catch (e) {
      throw Exception('Terjadi kesalahan sistem.');
    }
  }

  // 👇 FUNGSI 3: Menarik Dana (Withdraw) 👇
  Future<String> withdrawFunds({
    required String method,
    required String bankName,
    required String accountNumber,
    required String accountName,
    required num amount,
  }) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '$baseUrl/affiliate/withdraw',
        data: {
          'withdrawal_method': method,
          'bank_name': bankName,
          'account_number': accountNumber,
          'account_name': accountName,
          'amount': amount,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data['message'] ?? 'Penarikan dana berhasil diproses.';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menarik dana.');
    } catch (e) {
      throw Exception('Terjadi kesalahan sistem.');
    }
  }
}
