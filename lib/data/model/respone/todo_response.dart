import 'dart:convert';

class TodoResponseModel {
  final int id;
  final String description;
  final bool isDone;
  final int? userId;

  TodoResponseModel({
    required this.id,
    required this.description,
    required this.isDone,
    this.userId,
  });

  factory TodoResponseModel.fromJson(String str) =>
      TodoResponseModel.fromMap(json.decode(str));

  factory TodoResponseModel.fromMap(Map<String, dynamic> json) =>
      TodoResponseModel(
        id: json["id"],
        description: json["description"],
        isDone: json["is_done"] == 1 || json["is_done"] == true,
        userId: json["user_id"],
      );
}