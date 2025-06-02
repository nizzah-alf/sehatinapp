import 'package:equatable/equatable.dart';

class Todo {
  final int id;
  final String description;
  final bool isDone;
  final int? userId;

  Todo({
    required this.id,
    required this.description,
    required this.isDone,
    this.userId,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'],
    description: json['description'],
    isDone: json['is_done'] == 1,
    userId: json['user_id'],
  );
}

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;

  const TodoLoaded(this.todos);

  @override
  List<Object?> get props => [todos];
}

class TodoError extends TodoState {
  final String message;

  const TodoError(this.message);

  @override
  List<Object?> get props => [message];
}
