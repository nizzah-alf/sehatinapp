import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_repo.dart';
import 'package:sehatinapp/screen/page/moodEntery.dart';

class Variable {
  static const String baseUrl = 'https://sehatin.rm-rf.web.id/api';
}

class MoodRepository {
  final AuthRepository authRepository;
  final String baseUrl;

  MoodRepository({
    required this.authRepository,
    this.baseUrl = Variable.baseUrl,
  });

  Future<List<Map<String, dynamic>>> getMood({String? date}) async {
    final token = await authRepository.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final uri = Uri.parse('$baseUrl/get-mood').replace(
      queryParameters: date != null ? {'date': date} : null,
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == true) {
        final data = body['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          return [Map<String, dynamic>.from(data)];
        } else {
          return [];
        }
      } else {
        throw Exception(body['message'] ?? 'Gagal mengambil data mood');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Token tidak valid atau sudah expired');
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Gagal mengambil data mood: ${response.body}');
    }
  }

  /// Submit mood ke server
  Future<void> submitMood({
    required String kategori,
    required String image,
    required String catatan,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final uri = Uri.parse('$baseUrl/mood');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'kategori': kategori,
        'image': image,
        'catatan': catatan,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return; // sukses
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Token tidak valid atau sudah expired');
    } else {
      throw Exception('Gagal submit mood: ${response.body}');
    }
  }
  Future<List<MoodEntry>> fetchRecentMoods() async {
    final rawData = await getMood();
    return rawData
        .map((json) => MoodEntry.fromJson(json))
        .toList()
        .reversed
        .toList();
  }
}
