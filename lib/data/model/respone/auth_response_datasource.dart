import 'dart:convert';

class AuthResponseModel {
    final User? user;
    final String? token;

    AuthResponseModel({
        this.user,
        this.token,
    });

    factory AuthResponseModel.fromJson(String str) => AuthResponseModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory AuthResponseModel.fromMap(Map<String, dynamic> json) => AuthResponseModel(
        user: json["user"] == null ? null : User.fromMap(json["user"]),
        token: json["token"],
    );

    Map<String, dynamic> toMap() => {
        "user": user?.toMap(),
        "token": token,
    };
}

class User {
    final int? id;
    final String? name;
    final String? email;
    final String? role;
    final dynamic createdAt;
    final dynamic updatedAt;
    final String? image;

    User({
        this.id,
        this.name,
        this.email,
        this.role,
        this.createdAt,
        this.updatedAt,
        this.image,
    });

    factory User.fromJson(String str) => User.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        role: json["role"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        image: json["image"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "email": email,
        "role": role,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "image": image,
    };
}
