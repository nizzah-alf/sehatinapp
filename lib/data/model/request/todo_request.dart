import 'dart:convert';

class TodoRequestModel {
  final String description;
  final bool? isDone;
  final int? userId;

  TodoRequestModel({required this.description, this.isDone, this.userId});

  factory TodoRequestModel.fromJson(String str) =>
      TodoRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TodoRequestModel.fromMap(Map<String, dynamic> json) =>
      TodoRequestModel(
        description: json["description"],
        isDone: json["is_done"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toMap() => {
    "description": description,
    if (isDone != null) "is_done": isDone,
    if (userId != null) "user_id": userId,
  };
}
