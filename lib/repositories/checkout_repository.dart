import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/checkout_model.dart';

class CheckoutRepository {
  final Dio _dio = Dio();
  final String baseUrl = 'https://back.solher.co.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 1. Cek Ongkos Kirim (Biteship)
  Future<List<ShippingRateModel>> fetchShippingRates(
      int addressId, List<int> cartIds) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '$baseUrl/shipping/rates',
        data: {'address_id': addressId, 'cart_ids': cartIds},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final dataList = response.data['data'] ??
          response.data['rates'] ??
          response.data['pricing'] ??
          [];
      return (dataList as List)
          .map((e) => ShippingRateModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil tarif pengiriman.');
    }
  }

  // 2. Verifikasi Kode Promo
  Future<Map<String, dynamic>> verifyPromo(
      String promoCode, List<Map<String, dynamic>> cartItems) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '$baseUrl/promo/verify',
        data: {'promo_code': promoCode, 'cart_items': cartItems},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data; // Berisi discount_value, promo_type, message
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Kode Promo tidak valid.');
    }
  }

  // 3. Eksekusi Checkout
  Future<String> submitCheckout(Map<String, dynamic> payload) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '$baseUrl/checkout',
        data: payload,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'X-Idempotency-Key': DateTime.now()
              .millisecondsSinceEpoch
              .toString() // Pencegah double klik
        }),
      );
      return response.data['checkout_url']; // Link Xendit
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal membuat pesanan.');
    }
  }
}
