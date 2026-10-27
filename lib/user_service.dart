
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'user_model.dart';

class UserService {
  static const String _baseUrl = 'https://reqres.in/api';

  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'x-api-key': 'reqres-free-v1',
  };

  // GET: Mengambil daftar pengguna
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/users?page=1'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil data. HTTP ${response.statusCode}',
        );
      }

      final Map<String, dynamic> result =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic> data = result['data'] as List<dynamic>;

      return data
          .map(
            (item) => UserModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  // POST: Membuat pengguna baru
  Future<Map<String, dynamic>> createUser({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/users'),
            headers: _headers,
            body: jsonEncode({
              'first_name': firstName,
              'last_name': lastName,
              'email': email,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw Exception(
          'Gagal menambahkan pengguna. HTTP ${response.statusCode}',
        );
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  // PUT: Memperbarui data pengguna
  Future<Map<String, dynamic>> updateUser({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/users/$id'),
            headers: _headers,
            body: jsonEncode({
              'first_name': firstName,
              'last_name': lastName,
              'email': email,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memperbarui pengguna. HTTP ${response.statusCode}',
        );
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  // DELETE: Menghapus pengguna
  Future<void> deleteUser(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/users/$id'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 &&
          response.statusCode != 202 &&
          response.statusCode != 204) {
        throw Exception(
          'Gagal menghapus pengguna. HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  String _errorMessage(Object error) {
    if (error is SocketException) {
      return 'Tidak ada koneksi internet. Periksa jaringan kamu.';
    }

    if (error is TimeoutException) {
      return 'Permintaan terlalu lama. Silakan coba lagi.';
    }

    if (error is http.ClientException) {
      return 'Gagal menghubungi server. Periksa koneksi internet.';
    }

    if (error is FormatException) {
      return 'Format data dari server tidak valid.';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}
