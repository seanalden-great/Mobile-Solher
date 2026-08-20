import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductRepository {
  final Dio _dio = Dio();
  final String baseUrl = 'https://back.solher.co.id/api';

  Future<List<ProductModel>> fetchBestSellers() async {
    try {
      final response = await _dio.get('$baseUrl/home/best-sellers');
      final data = response.data['data'] as List;
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil Best Seller: $e');
    }
  }

  Future<List<ProductModel>> fetchActiveProducts() async {
    try {
      final response = await _dio.get('$baseUrl/products');
      final data = response.data as List;
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil Produk: $e');
    }
  }
}