import 'package:equatable/equatable.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class FetchTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final String description;

  const AddTodo(this.description);

  @override
  List<Object?> get props => [description];
}

class DeleteTodo extends TodoEvent {
  final int id;

  const DeleteTodo(this.id);

  @override
  List<Object?> get props => [id];
}
