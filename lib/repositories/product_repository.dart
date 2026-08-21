import 'package:dio/dio.dart';
import 'package:solher_mobile/models/product_model.dart';

class ProductRepository {
  final Dio _dio = Dio();
  final String baseUrl = 'https://back.solher.co.id/api';

  // 1. Ambil Semua Produk Aktif (Biasa)
  Future<List<ProductModel>> fetchActiveProducts() async {
    try {
      final response = await _dio.get('$baseUrl/products');
      // Format response Laravel: Langsung berupa Array (List)
      final data = response.data as List;
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil daftar produk: $e');
    }
  }

  // 2. Ambil Produk Best Seller
  Future<List<ProductModel>> fetchBestSellers() async {
    try {
      final response = await _dio.get('$baseUrl/home/best-sellers');
      // PERBAIKAN: Format response Laravel adalah { status: "success", data: [...] }
      final data = response.data['data'] as List;
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil Best Seller: $e');
    }
  }

  // 3. Cari Produk berdasarkan Keyword (Terhubung ke Meilisearch)
  Future<List<ProductModel>> searchProducts(String keyword) async {
    try {
      final response = await _dio.get(
        '$baseUrl/products/search',
        queryParameters: {'q': keyword},
      );
      final data = response.data as List;
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal melakukan pencarian: $e');
    }
  }

  // 4. Ambil Detail Produk Lengkap berdasarkan ID atau Slug
  Future<ProductModel> fetchProductDetail(String identifier) async {
    try {
      final response = await _dio.get('$baseUrl/products/$identifier');
      return ProductModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Gagal mengambil detail produk: $e');
    }
  }

  // 5. Ambil Daftar Produk Inaktif (Jika sewaktu-waktu dibutuhkan)
  Future<List<ProductModel>> fetchInactiveProducts() async {
    try {
      final response = await _dio.get('$baseUrl/products/inactive');
      final data = response.data as List;
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil produk inaktif: $e');
    }
  }

  // 6. Ambil Produk Berdasarkan ID Kategori
  Future<List<ProductModel>> fetchProductsByCategory(int categoryId) async {
    try {
      // Sesuaikan endpoint ini dengan route Laravel Anda.
      // Umumnya menggunakan query parameter seperti ?category_id=1
      final response = await _dio.get(
        '$baseUrl/products',
        queryParameters: {'category_id': categoryId},
      );

      // Jika format response Laravel Anda berupa array langsung
      final data = response.data as List;

      // Jika formatnya dibungkus 'data' ( { status: "success", data: [...] } ), gunakan ini:
      // final data = response.data['data'] as List;

      return data.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil produk untuk kategori ini: $e');
    }
  }
}
