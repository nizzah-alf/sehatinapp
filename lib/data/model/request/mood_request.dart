import 'dart:convert';

class MoodRequestModel {
  final int? userId;
  final String? kategori;
  final String? image;
  final String? catatan;

  MoodRequestModel({this.userId, this.kategori, this.image, this.catatan});

  factory MoodRequestModel.fromJson(String str) =>
      MoodRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MoodRequestModel.fromMap(Map<String, dynamic> json) =>
      MoodRequestModel(
        userId: json["user_id"],
        kategori: json["kategori"],
        image: json["image"],
        catatan: json["catatan"],
      );

  Map<String, dynamic> toMap() => {
    "user_id": userId,
    "kategori": kategori,
    "image": image,
    "catatan": catatan,
  };
}
