import 'dart:convert';

class MoodResponseModel {
    final String? status;
    final String? message;
    final Data? data;

    MoodResponseModel({
        this.status,
        this.message,
        this.data,
    });

    factory MoodResponseModel.fromJson(String str) => MoodResponseModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory MoodResponseModel.fromMap(Map<String, dynamic> json) => MoodResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
    );

    Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": data?.toMap(),
    };
}

class Data {
    final int? userId;
    final String? kategori;
    final String? image;
    final String? catatan;
    final DateTime? updatedAt;
    final DateTime? createdAt;
    final int? id;

    Data({
        this.userId,
        this.kategori,
        this.image,
        this.catatan,
        this.updatedAt,
        this.createdAt,
        this.id,
    });

    factory Data.fromJson(String str) => Data.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Data.fromMap(Map<String, dynamic> json) => Data(
        userId: json["user_id"],
        kategori: json["kategori"],
        image: json["image"],
        catatan: json["catatan"],
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        id: json["id"],
    );

    Map<String, dynamic> toMap() => {
        "user_id": userId,
        "kategori": kategori,
        "image": image,
        "catatan": catatan,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "id": id,
    };
}
