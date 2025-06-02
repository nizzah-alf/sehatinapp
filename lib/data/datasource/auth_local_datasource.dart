import 'package:sehatinapp/data/model/respone/auth_response_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDatasource {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> saveAuthData(AuthResponseModel data) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setString('auth_data', data.toJson());

    if (data.token != null) {
      await _secureStorage.write(key: 'token', value: data.token);
    }
    await _secureStorage.write(key: 'userName', value: data.user?.name ?? '');
    await _secureStorage.write(key: 'userEmail', value: data.user?.email ?? '');
    await _secureStorage.write(key: 'photoUrl', value: data.user?.image ?? '');
  }

  Future<void> removeAuthData() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove('auth_data');

    await _secureStorage.deleteAll();
  }

  Future<AuthResponseModel> getAuthData() async {
    final pref = await SharedPreferences.getInstance();
    final data = pref.getString('auth_data');

    if (data != null) {
      return AuthResponseModel.fromJson(data);
    } else {
      throw Exception('No auth data found');
    }
  }

  Future<bool> isLogin() async {
    final pref = await SharedPreferences.getInstance();
    return pref.containsKey('auth_data');
  }
}
