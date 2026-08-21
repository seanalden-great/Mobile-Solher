import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solher_mobile/models/category_model.dart';

class CategoryRepository {
  final String baseUrl = 'https://back.solher.co.id/api'; // Sesuaikan URL

  // Future<List<Category>> getCategories() async {
  //   final response = await http.get(Uri.parse('$baseUrl/categories'));

  //   if (response.statusCode == 200) {
  //     final decodedData = json.decode(response.body)['data'] as List;
  //     return decodedData.map((e) => Category.fromJson(e)).toList();
  //   } else {
  //     throw Exception('Failed to load categories');
  //   }
  // }

  // Future<List<Category>> getCategories() async {
  //   try {
  //     final response = await http.get(Uri.parse('$baseUrl/categories'));

  //     if (response.statusCode == 200) {
  //       final decoded = json.decode(response.body);
  //       // Jaga-jaga jika format Laravel langsung mengembalikan array tanpa bungkus 'data'
  //       final List dataList = decoded is List ? decoded : decoded['data'];
  //       return dataList.map((e) => Category.fromJson(e)).toList();
  //     } else {
  //       // MEMUNCULKAN PESAN ASLI DARI BACKEND
  //       throw Exception('Error ${response.statusCode}: ${response.body}');
  //     }
  //   } catch (e) {
  //     throw Exception('$e');
  //   }
  // }

  Future<List<Category>> getCategories() async {
    try {
      // 👇 Ubah /categories menjadi /guest/categories 👇
      final response = await http.get(Uri.parse('$baseUrl/guest/categories'));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List dataList = decoded is List ? decoded : decoded['data'];
        return dataList.map((e) => Category.fromJson(e)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<Category> getCategoryById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/categories/$id'));

    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load category detail');
    }
  }

  Future<Category> createCategory(Category category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: json.encode(category.toJson()),
    );

    if (response.statusCode == 201) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create category');
    }
  }

  Future<Category> updateCategory(int id, Category category) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categories/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: json.encode(category.toJson()),
    );

    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update category');
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 409) {
      final message = json.decode(response.body)['message'];
      throw Exception(
          message); // "Cannot delete category because it contains products."
    } else {
      throw Exception('Failed to delete category');
    }
  }
}
