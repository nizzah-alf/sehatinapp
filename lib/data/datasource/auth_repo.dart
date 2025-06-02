import 'dart:io';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sehatinapp/data/model/respone/artikel_response.dart';
import 'package:sehatinapp/data/model/artikel_category_model.dart';

class Variable {
  static const String baseUrl = 'https://sehatin.site/api';
  //'https://sehatin.rm-rf.web.id/api' 
}

class AuthRepository {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = Variable.baseUrl;

  // TOKEN
  Future<String?> getToken() async => await _storage.read(key: 'token');
  Future<void> saveToken(String token) async => await _storage.write(key: 'token', value: token);

  // USER NAME
  Future<String?> getUserName() async => await _storage.read(key: 'userName');
  Future<void> saveUserName(String userName) async => await _storage.write(key: 'userName', value: userName);

  // USER USERNAME
  Future<String?> getUserUsername() async => await _storage.read(key: 'userUsername');
  Future<void> saveUserUsername(String username) async => await _storage.write(key: 'userUsername', value: username);

  // USER EMAIL
  Future<String?> getUserEmail() async => await _storage.read(key: 'userEmail');
  Future<void> saveUserEmail(String email) async => await _storage.write(key: 'userEmail', value: email);

  // USER PHOTO URL
  Future<String?> getPhotoUrl() async => await _storage.read(key: 'photoUrl');
  Future<void> saveUserPhoto(String photoUrl) async => await _storage.write(key: 'photoUrl', value: photoUrl);

  // CLEAR ALL DATA
  Future<void> clearStorage() async => await _storage.deleteAll();

  // LOGIN
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'}, // tambahkan header json
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = data['user'];

      await saveToken(token);
      if (user != null) {
        if (user['name'] != null) await saveUserName(user['name']);
        if (user['email'] != null) await saveUserEmail(user['email']);
        if (user['image'] != null) await saveUserPhoto(user['image']);
        if (user['username'] != null) await saveUserUsername(user['username']);
      }

      return token;
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Login gagal');
      } catch (_) {
        throw Exception('Login gagal. Tidak ada data dari server.');
      }
    }
  }

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    final body = jsonDecode(response.body);

    if (body['message'] == 'Registrasi berhasil') {
      if (body.containsKey('token')) {
        await saveToken(body['token']);
      }
      if (body.containsKey('user')) {
        final user = body['user'];
        if (user != null) {
          if (user['name'] != null) await saveUserName(user['name']);
          if (user['email'] != null) await saveUserEmail(user['email']);
          if (user['username'] != null) await saveUserUsername(user['username']);
          if (user['image'] != null) await saveUserPhoto(user['image']);
        }
      }
      return body;
    } else {
      throw Exception(body['message'] ?? 'Registrasi gagal');
    }
  }

  // LOGOUT
  Future<void> logout() async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await clearStorage();
    } else {
      throw Exception('Logout gagal: ${response.statusCode} - ${response.body}');
    }
  }

  // FETCH ARTIKEL CATEGORY
  Future<List<ArtikelCategory>> fetchCategories(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((e) => ArtikelCategory.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }

  // FETCH ARTIKEL
  Future<List<Artikel>> fetchArticles(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/artikel'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((e) => Artikel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil artikel: ${response.statusCode}');
    }
  }

  // UPDATE PROFILE
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.post(
      Uri.parse('$baseUrl/update-profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];

      if (user != null) {
        if (user['name'] != null) await saveUserName(user['name']);
        if (user['email'] != null) await saveUserEmail(user['email']);
        if (user['username'] != null) await saveUserUsername(user['username']);
        if (user['image'] != null) await saveUserPhoto(user['image']);
      }

      return data;
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal update profil');
      } catch (_) {
        throw Exception('Gagal update profil (format tidak valid)');
      }
    }
  }

  // UPDATE PROFILE IMAGE
  Future<void> updateProfileImage(File imageFile) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final uri = Uri.parse('$baseUrl/update-profile-image');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json'
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];
      if (user != null) {
        if (user['name'] != null) await saveUserName(user['name']);
        if (user['email'] != null) await saveUserEmail(user['email']);
        if (user['username'] != null) await saveUserUsername(user['username']);
        if (user['image'] != null) await saveUserPhoto(user['image']);
      }
    } else {
      throw Exception('Gagal update foto profil');
    }
  }

  // TODO LIST FUNCTIONS 
  Future<List<Map<String, dynamic>>> fetchTodos() async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$baseUrl/todolist'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List todos = data['data'];
      return List<Map<String, dynamic>>.from(todos);
    } else {
      throw Exception('Gagal mengambil todo: ${response.body}');
    }
  }

  Future<void> updateTodoStatus(int id, bool isDone) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.put(
      Uri.parse('$baseUrl/todolist/$id/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'is_done': isDone}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal update status todo: ${response.body}');
    }
  }

  // ADD TODO
  Future<Map<String, dynamic>> addTodo(String description) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.post(
      Uri.parse('$baseUrl/todolist'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'description': description}),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return body['data'];
    } else {
      throw Exception('Gagal tambah todo');
    }
  }
   
  //DELETE TODO
  Future<void> deleteTodo(int id) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.delete(
      Uri.parse('$baseUrl/todolist/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus todo: ${response.body}');
    }
  }

  Future<void> toggleActivityStatus(int id, bool isDone) async {
    await updateTodoStatus(id, isDone);
  }
}








// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:sehatinapp/data/model/respone/artikel_response.dart';
// import 'package:sehatinapp/data/model/artikel_category_model.dart';

// class AuthRepository {
//   final _storage = const FlutterSecureStorage();
//   // Pastikan baseUrl sudah mengarah ke endpoint API, biasanya ada /api di belakang
//   final String baseUrl = 'https://sehatin.site';

//   // TOKEN
//   Future<String?> getToken() async => await _storage.read(key: 'token');
//   Future<void> saveToken(String token) async => await _storage.write(key: 'token', value: token);

//   // USER NAME
//   Future<String?> getUserName() async => await _storage.read(key: 'userName');
//   Future<void> saveUserName(String userName) async => await _storage.write(key: 'userName', value: userName);

//   // USER USERNAME
//   Future<String?> getUserUsername() async => await _storage.read(key: 'userUsername');
//   Future<void> saveUserUsername(String username) async => await _storage.write(key: 'userUsername', value: username);

//   // USER EMAIL
//   Future<String?> getUserEmail() async => await _storage.read(key: 'userEmail');
//   Future<void> saveUserEmail(String email) async => await _storage.write(key: 'userEmail', value: email);

//   // USER PHOTO URL
//   Future<String?> getPhotoUrl() async => await _storage.read(key: 'photoUrl');
//   Future<void> saveUserPhoto(String photoUrl) async => await _storage.write(key: 'photoUrl', value: photoUrl);

//   // CLEAR ALL DATA
//   Future<void> clearStorage() async => await _storage.deleteAll();

//   // LOGIN
//   Future<String?> login(String email, String password) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/login'),
//       body: {'email': email, 'password': password},
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final token = data['token'];
//       final user = data['user'];

//       await saveToken(token);
//       if (user != null) {
//         if (user['name'] != null) await saveUserName(user['name']);
//         if (user['email'] != null) await saveUserEmail(user['email']);
//         if (user['image'] != null) await saveUserPhoto(user['image']);
//       }

//       return token;
//     } else {
//       try {
//         final data = jsonDecode(response.body);
//         throw Exception(data['message'] ?? 'Login gagal');
//       } catch (_) {
//         throw Exception('Login gagal. Tidak ada data dari server.');
//       }
//     }
//   }

//   // REGISTER
//   Future<Map<String, dynamic>> register({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/register'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'name': name,
//         'email': email,
//         'password': password,
//         'password_confirmation': password,
//       }),
//     );

//     final body = jsonDecode(response.body);

//     if (body['message'] == 'Registrasi berhasil') {
//       if (body.containsKey('token')) {
//         await saveToken(body['token']);
//       }
//       if (body.containsKey('user')) {
//         final user = body['user'];
//         if (user != null) {
//           if (user['name'] != null) await saveUserName(user['name']);
//           if (user['email'] != null) await saveUserEmail(user['email']);
//           if (user['username'] != null) await saveUserUsername(user['username']);
//           if (user['image'] != null) await saveUserPhoto(user['image']);
//         }
//       }
//       return body;
//     } else {
//       throw Exception(body['message'] ?? 'Registrasi gagal');
//     }
//   }

//   // LOGOUT
//   Future<void> logout() async {
//     final token = await getToken();
//     if (token == null) throw Exception('Token tidak ditemukan');

//     final response = await http.post(
//       Uri.parse('$baseUrl/logout'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode == 200) {
//       await clearStorage();
//     } else {
//       throw Exception('Logout gagal: ${response.statusCode} - ${response.body}');
//     }
//   }

//   // FETCH ARTIKEL CATEGORY
//   Future<List<ArtikelCategory>> fetchCategories(String token) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/categories'),
//       headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       final body = jsonDecode(response.body);
//       final List<dynamic> data = body['data'];
//       return data.map((e) => ArtikelCategory.fromJson(e)).toList();
//     } else {
//       throw Exception('Gagal memuat kategori');
//     }
//   }

//   // FETCH ARTIKEL
//   Future<List<Artikel>> fetchArticles(String token) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/artikel'),
//       headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       final body = jsonDecode(response.body);
//       final List<dynamic> data = body['data'];
//       return data.map((e) => Artikel.fromJson(e)).toList();
//     } else {
//       throw Exception('Gagal mengambil artikel: ${response.statusCode}');
//     }
//   }

//   // UPDATE PROFILE
//   Future<Map<String, dynamic>> updateProfile({
//     required String name,
//     required String email,
//   }) async {
//     final token = await getToken();
//     if (token == null) throw Exception('Token tidak ditemukan');

//     final response = await http.post(
//       Uri.parse('$baseUrl/update-profile'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//       body: jsonEncode({
//         'name': name,
//         'email': email,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final user = data['user'];

//       if (user != null) {
//         if (user['name'] != null) await saveUserName(user['name']);
//         if (user['email'] != null) await saveUserEmail(user['email']);
//         if (user['username'] != null) await saveUserUsername(user['username']);
//         if (user['image'] != null) await saveUserPhoto(user['image']);
//       }

//       return data;
//     } else {
//       try {
//         final data = jsonDecode(response.body);
//         throw Exception(data['message'] ?? 'Gagal update profil');
//       } catch (_) {
//         throw Exception('Gagal update profil (format tidak valid)');
//       }
//     }
//   }

//   // UPDATE PROFILE IMAGE
//   Future<void> updateProfileImage(File imageFile) async {
//     final token = await getToken();
//     if (token == null) throw Exception('Token tidak ditemukan');

//     final uri = Uri.parse('$baseUrl/update-profile-image');
//     final request = http.MultipartRequest('POST', uri)
//       ..headers['Authorization'] = 'Bearer $token'
//       ..headers['Accept'] = 'application/json'
//       ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final user = data['user'];
//       if (user != null) {
//         if (user['name'] != null) await saveUserName(user['name']);
//         if (user['email'] != null) await saveUserEmail(user['email']);
//         if (user['username'] != null) await saveUserUsername(user['username']);
//         if (user['image'] != null) await saveUserPhoto(user['image']);
//       }
//     } else {
//       throw Exception('Gagal update foto profil');
//     }
//   }

//   // TODO LIST FUNCTIONS 
//   Future<List<Map<String, dynamic>>> fetchTodos() async {
//     final token = await getToken();
//     if (token == null) throw Exception('Token tidak ditemukan');

//     final response = await http.get(
//       Uri.parse('$baseUrl/todolist'),
//       headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final List todos = data['data'];
//       return List<Map<String, dynamic>>.from(todos);
//     } else {
//       throw Exception('Gagal mengambil todo: ${response.body}');
//     }
//   }

//   Future<void> updateTodoStatus(int id, bool isDone) async {
//     final token = await getToken();
//     if (token == null) throw Exception('Token tidak ditemukan');

//     final response = await http.put(
//       Uri.parse('$baseUrl/todolist/$id/status'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({'is_done': isDone}),
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Gagal update status todo: ${response.body}');
//     }
//   }

//   // ADD TODO
//   Future<Map<String, dynamic>> addTodo(String description) async {
//     final token = await getToken();
//     if (token == null) throw Exception('Token tidak ditemukan');

//     final response = await http.post(
//       Uri.parse('$baseUrl/todolist'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({'description': description}),
//     );

//     if (response.statusCode == 201) {
//       final body = jsonDecode(response.body);
//       return body['data'];
//     } else {
//       throw Exception('Gagal tambah todo');
//     }
//   }
   
//    //DELETE TODO
//   Future<void> deleteTodo(int id) async {
//     final token = await getToken();
//     if (token == null) throw Exception('Token tidak ditemukan');

//     final response = await http.delete(
//       Uri.parse('$baseUrl/todolist/$id'),
//       headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
//     );

//     if (response.statusCode != 200 && response.statusCode != 204) {
//       throw Exception('Gagal menghapus todo: ${response.body}');
//     }
//   }

//   Future<void> toggleActivityStatus(int id, bool isDone) async {
//     await updateTodoStatus(id, isDone);
//   }
// }
