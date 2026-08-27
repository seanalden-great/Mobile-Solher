import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';

class CartRepository {
  final Dio _dio = Dio();
  final String baseUrl = 'https://back.solher.co.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Ambil daftar keranjang
  Future<Map<String, dynamic>> fetchCarts({String currency = 'IDR'}) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$baseUrl/carts',
        queryParameters: {'currency': currency},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final items = (response.data['items'] as List)
          .map((e) => CartModel.fromJson(e))
          .toList();
      final summary = CartSummaryModel.fromJson(response.data['summary']);

      return {'items': items, 'summary': summary};
    } catch (e) {
      throw Exception('Gagal mengambil data keranjang.');
    }
  }

  // Tambah ke keranjang
  Future<void> addToCart(int productId, int quantity, String color) async {
    try {
      final token = await _getToken();
      await _dio.post(
        '$baseUrl/carts',
        data: {'product_id': productId, 'quantity': quantity, 'color': color},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal menambah ke keranjang.');
    }
  }

  // Update jumlah qty
  Future<void> updateCartQty(int cartId, int quantity) async {
    try {
      final token = await _getToken();
      await _dio.put(
        '$baseUrl/carts/$cartId',
        data: {'quantity': quantity},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengubah jumlah.');
    }
  }

  // Hapus dari keranjang
  Future<void> deleteCartItem(int cartId) async {
    try {
      final token = await _getToken();
      await _dio.delete(
        '$baseUrl/carts/$cartId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Gagal menghapus barang.');
    }
  }

  // Tambahkan fungsi baru ini di CartRepository
  Future<int> buyNowReturnId(int productId, int quantity, String color) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '$baseUrl/carts',
        data: {'product_id': productId, 'quantity': quantity, 'color': color},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // Mengambil ID keranjang yang baru saja di-generate oleh backend
      return response.data['cart_id'] ??
          response.data['id'] ??
          response.data['data']['id'];
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal memproses Buy Now.');
    }
  }
}
