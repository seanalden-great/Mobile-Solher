import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solher_mobile/models/address_model.dart'; // Sesuaikan package

class AddressRepository {
  final String baseUrl = 'https://back.solher.co.id/api';

  // Fungsi helper untuk menyematkan Token Otentikasi
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AddressModel>> getAddresses() async {
    final headers = await _getHeaders();
    final response =
        await http.get(Uri.parse('$baseUrl/addresses'), headers: headers);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final List dataList =
          decodedData is List ? decodedData : decodedData['data'];
      return dataList.map((e) => AddressModel.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesi telah berakhir. Silakan login kembali.');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<AddressModel> createAddress(AddressModel address) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/addresses'),
      headers: headers,
      body: json.encode(address.toJson()),
    );

    if (response.statusCode == 201) {
      return AddressModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal menambah alamat: ${response.body}');
    }
  }

  Future<AddressModel> updateAddress(int id, AddressModel address) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/addresses/$id'),
      headers: headers,
      body: json.encode(address.toJson()),
    );

    if (response.statusCode == 200) {
      return AddressModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memperbarui alamat: ${response.body}');
    }
  }

  Future<void> deleteAddress(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/addresses/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus alamat: ${response.body}');
    }
  }
}
