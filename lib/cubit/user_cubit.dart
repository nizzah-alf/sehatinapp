import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserCubit extends Cubit<Map<String, String?>> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserCubit() : super({});

  Future<void> loadUserData() async {
    final name = await _storage.read(key: 'userName');
    final email = await _storage.read(key: 'userEmail');
    final photoUrl = await _storage.read(key: 'photoUrl');

    emit({'name': name, 'email': email, 'photoUrl': photoUrl});
  }

  Future<void> updatePhotoUrl(String? url) async {
    await _storage.write(key: 'photoUrl', value: url);
    await loadUserData();
  }

  Future<void> updateUserName(String? name) async {
    await _storage.write(key: 'userName', value: name);
    await loadUserData();
  }

  Future<void> updateEmail(String? email) async {
    await _storage.write(key: 'userEmail', value: email);
    await loadUserData();
  }
}
