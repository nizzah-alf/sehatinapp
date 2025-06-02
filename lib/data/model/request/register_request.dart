import 'dart:convert';

class RegisterRequestModel {
  final String? name;
  final String? username;
  final String? phone;
  final String? email;
  final String? password;

  RegisterRequestModel({
    this.name,
    this.username,
    this.phone,
    this.email,
    this.password,
  });

  factory RegisterRequestModel.fromJson(String str) =>
      RegisterRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RegisterRequestModel.fromMap(Map<String, dynamic> json) =>
      RegisterRequestModel(
        name: json["name"],
        username: json["username"],
        phone: json["phone"],
        email: json["email"],
        password: json["password"],
      );

  Map<String, dynamic> toMap() => {
    "name": name,
    "username": username,
    "phone": phone,
    "email": email,
    "password": password,
  };
}
