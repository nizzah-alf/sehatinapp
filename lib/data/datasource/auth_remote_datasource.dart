import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:dartz/dartz.dart';
import 'package:sehatinapp/data/datasource/auth_local_datasource.dart';
import 'package:sehatinapp/data/datasource/variable.dart';
import 'package:sehatinapp/data/model/request/auth_request.dart';
import 'package:sehatinapp/data/model/request/register_request.dart';
import 'package:sehatinapp/data/model/respone/auth_response_datasource.dart';

class AuthRemoteDatasource {
  //login
  Future<Either<String, AuthResponseModel>> login(AuthRequestModel data) async {
    final response = await http.post(
      Uri.parse('${Variable.baseUrl}/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      },
      body: data.toJson(),
    );

    if (response.statusCode == 200) {
      return Right(AuthResponseModel.fromJson(response.body));
    } else {
      return Left(response.body);
    }
  }

  //register
  Future<Either<String, AuthResponseModel>> register(
    RegisterRequestModel data,
  ) async {
    print('Register data : $data.toJson()');
    try {
      final response = await http.post(
        Uri.parse('${Variable.baseUrl}/api/register'),
        headers: <String, String>{
          'Accept':
              'application/json; charset=UTF-8', 
          'Content-Type': 'application/json',
        },
        body: data.toJson(),
      );

      print('Register response : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(AuthResponseModel.fromJson(response.body));
      } else {
        return Left(response.body);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Logout
  Future<Either<String, String>> logout() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.post(
      Uri.parse('${Variable.baseUrl}/api/logout'),
      headers: <String, String>{
        'Authorization': 'Bearer ${authData.token}',
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Right('Logout berhasil');
    } else {
      return Left(response.body);
    }
  }

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
        final jsonResponse = json.decode(response.body);
        final authResponse = AuthResponseModel.fromMap({
          'user': jsonResponse['user'],
          'token': authData.token,
        });

        await AuthLocalDatasource().saveAuthData(authResponse);

        return Right(authResponse);
      } else {
        print('Gagal unggah gambar: ${response.statusCode}');
        print('Response body: ${response.body}');
        return Left(response.body);
      }
    } catch (e) {
      print('Error: $e');
      return Left(e.toString());
    }
  }
}
