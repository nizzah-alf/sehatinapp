import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sehatinapp/data/datasource/auth_repo.dart';

class LikeRepository {
  final AuthRepository authRepository;

  LikeRepository({required this.authRepository});

  Future<String> get _token async {
    final token = await authRepository.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');
    return token;
  }

  String get baseUrl => authRepository.baseUrl;

  Future<void> toggleLike(int articleId) async {
    final token = await _token;
    // Ganti 'artikel' jadi 'artikels' sesuai route Laravel
    final url = Uri.parse('$baseUrl/artikels/$articleId/like');

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal toggle like: ${response.body}');
    }
  }

  Future<Map<int, bool>> fetchLikedArticles() async {
    final token = await _token;
    final url = Uri.parse('$baseUrl/user/liked-articles');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal ambil liked articles: ${response.body}');
    }

    if (response.body.trim().isEmpty) return {};

    final data = json.decode(response.body);
    final List liked = data is List ? data : (data['data'] ?? []);

    print('DEBUG: Raw liked articles data: $liked');

    final Map<int, bool> result = {};

    for (var item in liked) {
      int? articleId;

      if (item is Map && item.containsKey('artikel_id')) {
        // Sesuaikan juga key 'artikel_id' (bukan 'article_id') sesuai backend
        articleId = int.tryParse(item['artikel_id'].toString());
      } else {
        articleId = int.tryParse(item.toString());
      }

      if (articleId != null && articleId > 0) {
        result[articleId] = true;
      }
    }

    return result;
  }

  Future<Map<int, int>> fetchLikeCounts() async {
    final token = await _token;
    final url = Uri.parse('$baseUrl/like-counts');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal ambil like counts: ${response.body}');
    }

    final data = json.decode(response.body);
    final Map counts = data['data'];

    return counts.map((key, value) => MapEntry(int.parse(key), value as int));
  }
}
