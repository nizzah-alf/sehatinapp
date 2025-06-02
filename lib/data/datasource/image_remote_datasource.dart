import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:sehatinapp/data/datasource/auth_local_datasource.dart';
import 'package:sehatinapp/data/datasource/variable.dart';
import 'package:sehatinapp/data/model/respone/auth_response_datasource.dart';

class ImageRemoteDatasource {
  Future<Either<String, AuthResponseModel>> updateProfileImage(
    File imageFile,
  ) async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      final url = Uri.parse('${Variable.baseUrl}/api/update-profile-image');
      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
      });

      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = authResponseModelFromJson(response.body);
        return Right(jsonResponse);
      } else {
        print('Upload failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        return Left('Gagal upload gambar: ${response.body}');
      }
    } catch (e) {
      print('Exception caught: $e');
      return Left('Terjadi kesalahan: $e');
    }
  }
}

AuthResponseModel authResponseModelFromJson(String str) {
  final data = json.decode(str);
  return AuthResponseModel.fromMap({
    "user": data['user'],
    "token": data['token'] ?? "",
  });
}
