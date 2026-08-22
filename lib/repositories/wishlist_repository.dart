import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wishlist_model.dart';

class WishlistRepository {
  final Dio _dio = Dio();
  final String baseUrl = 'https://back.solher.co.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<WishlistModel>> fetchWishlists() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$baseUrl/wishlists',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data as List;
      return data.map((e) => WishlistModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil daftar favorit.');
    }
  }

  Future<Map<String, dynamic>> toggleWishlist(int productId) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '$baseUrl/wishlists/toggle',
        data: {'product_id': productId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      throw Exception('Gagal mengubah status favorit.');
    }
  }
}
