// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:solher_mobile/models/transaction_models.dart';

// class OrderRepository {
//   final Dio _dio = Dio();
//   final String baseUrl = 'https://back.solher.co.id/api';

//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }

//   Future<List<TransactionModel>> fetchOrders() async {
//     try {
//       final token = await _getToken();
//       final response = await _dio.get(
//         '$baseUrl/transactions',
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );
//       final data = response.data as List;
//       return data.map((e) => TransactionModel.fromJson(e)).toList();
//     } catch (e) {
//       throw Exception('Gagal mengambil riwayat pesanan.');
//     }
//   }

//   Future<void> cancelOrder(int id) async {
//     try {
//       final token = await _getToken();
//       await _dio.post(
//         '$baseUrl/transactions/$id/cancel',
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );
//     } catch (e) {
//       if (e is DioException) {
//         throw Exception(
//             e.response?.data['message'] ?? 'Gagal membatalkan pesanan.');
//       }
//       throw Exception('Terjadi kesalahan sistem.');
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_models.dart'; // Sesuaikan path

class OrderRepository {
  final Dio _dio = Dio();
  final String baseUrl = 'https://back.solher.co.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 1. Fetch All Orders
  Future<List<TransactionModel>> fetchOrders() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$baseUrl/transactions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data as List;
      return data.map((e) => TransactionModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil riwayat pesanan.');
    }
  }

  // 2. Fetch Single Order (Show)
  Future<TransactionModel> fetchOrderDetail(int id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$baseUrl/transactions/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return TransactionModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Gagal mengambil detail pesanan.');
    }
  }

  // 3. Checkout
  Future<Map<String, dynamic>> checkout(
      Map<String, dynamic> checkoutData) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '$baseUrl/checkout',
        data: checkoutData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data; // Biasanya mengembalikan data invoice/checkout_url
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Checkout gagal.');
    }
  }

  // 4. Cancel Order
  Future<void> cancelOrder(int id) async {
    try {
      final token = await _getToken();
      await _dio.post(
        '$baseUrl/transactions/$id/cancel',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal membatalkan pesanan.');
    }
  }

  // 5. Confirm Complete
  Future<void> confirmComplete(int id) async {
    try {
      final token = await _getToken();
      await _dio.post(
        '$baseUrl/transactions/$id/confirm',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal menyelesaikan pesanan.');
    }
  }

  // 6. Request Refund (dengan Upload File)
  Future<void> requestRefund(int id, String reason, String filePath) async {
    try {
      final token = await _getToken();

      // Menggunakan FormData untuk mendukung multipart/form-data
      final formData = FormData.fromMap({
        'reason': reason,
        'proof_file': await MultipartFile.fromFile(filePath),
      });

      await _dio.post(
        '$baseUrl/transactions/$id/refund-request',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        }),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal mengajukan refund.');
    }
  }

  // 7. Process Refund (User mengeksekusi dana ke Xendit)
  Future<void> processRefundUser(int id) async {
    try {
      final token = await _getToken();
      await _dio.post(
        '$baseUrl/transactions/$id/refund-process',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal memproses pengembalian dana.');
    }
  }

  // 8. Track Order (Single)
  Future<Map<String, dynamic>> trackOrder(int id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$baseUrl/transactions/$id/tracking',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal melacak pesanan.');
    }
  }

  // 9. Bulk Track Orders
  Future<Map<String, dynamic>> bulkTrackOrders(List<int> transactionIds) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '$baseUrl/transactions/tracking/bulk',
        data: {'transaction_ids': transactionIds},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal melacak massal pesanan.');
    }
  }
}
