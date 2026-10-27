import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/user_model.dart';

/// Exception khusus agar pesan error mudah ditampilkan ke pengguna.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Mengubah error apa pun menjadi pesan yang ramah untuk pengguna.
String errorMessage(Object error) {
  if (error is ApiException) return error.message;
  return 'Terjadi kesalahan tak terduga: $error';
}

class UserService {
  static const String _baseUrl = 'https://reqres.in/api';

  // TODO: ganti dengan API key gratis Anda dari https://app.reqres.in
  static const String _apiKey = 'free_user_3LGXdGlID8muC48TiTqNxIqHiTm';

  static const Duration _timeout = Duration(seconds: 15);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-api-key': _apiKey,
  };

  // ---------------------------------------------------------------------------
  // READ - GET /users?page=1
  // ---------------------------------------------------------------------------
  Future<List<UserModel>> getUsers({int page = 1}) async {
    final response = await _send(
      () =>
          http.get(Uri.parse('$_baseUrl/users?page=$page'), headers: _headers),
    );
    _checkStatus(response, const [200]);

    final body = _decode(response.body);
    final list = body['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // CREATE - POST /users
  // ---------------------------------------------------------------------------
  Future<UserModel> createUser({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final payload = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };

    final response = await _send(
      () => http.post(
        Uri.parse('$_baseUrl/users'),
        headers: _headers,
        body: jsonEncode(payload),
      ),
    );
    _checkStatus(response, const [200, 201]);

    return UserModel.fromJson(_decode(response.body));
  }

  // ---------------------------------------------------------------------------
  // UPDATE - PUT /users/{id}
  // ---------------------------------------------------------------------------
  Future<UserModel> updateUser(
    UserModel user, {
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final payload = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };

    final response = await _send(
      () => http.put(
        Uri.parse('$_baseUrl/users/${user.id}'),
        headers: _headers,
        body: jsonEncode(payload),
      ),
    );
    _checkStatus(response, const [200, 201]);

    final data = _decode(response.body);
    // Response PUT hanya mengembalikan field yang dikirim, jadi avatar
    // dipertahankan dari data lama.
    return user.copyWith(
      firstName: (data['first_name'] ?? firstName) as String,
      lastName: (data['last_name'] ?? lastName) as String,
      email: (data['email'] ?? email) as String,
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE - DELETE /users/{id}
  // ---------------------------------------------------------------------------
  Future<void> deleteUser(int id) async {
    final response = await _send(
      () => http.delete(Uri.parse('$_baseUrl/users/$id'), headers: _headers),
    );
    // DELETE yang berhasil mengembalikan 204 (No Content).
    _checkStatus(response, const [200, 204]);
  }

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  /// Membungkus request dengan try-catch untuk masalah koneksi.
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on SocketException {
      throw ApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on http.ClientException {
      throw ApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on TimeoutException {
      throw ApiException('Server terlalu lama merespons. Silakan coba lagi.');
    }
  }

  /// Melempar ApiException jika status code tidak termasuk yang diharapkan.
  void _checkStatus(http.Response response, List<int> expected) {
    if (expected.contains(response.statusCode)) return;

    final code = response.statusCode;
    String message;
    if (code == 401 || code == 403) {
      message = 'Akses ditolak ($code). Periksa API key Anda.';
    } else if (code == 404) {
      message = 'Data tidak ditemukan (404).';
    } else if (code == 429) {
      message = 'Terlalu banyak request (429). Tunggu sebentar lalu coba lagi.';
    } else if (code >= 500) {
      message = 'Server sedang bermasalah ($code). Coba lagi nanti.';
    } else {
      message = 'Request gagal dengan status code $code.';
    }
    throw ApiException(message, statusCode: code);
  }

  Map<String, dynamic> _decode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } on FormatException {
      throw ApiException('Format data dari server tidak valid.');
    }
  }
}
