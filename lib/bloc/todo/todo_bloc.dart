import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final AuthRepository repository;

  TodoBloc(this.repository) : super(TodoInitial()) {
    on<FetchTodos>(_onFetchTodos);
    on<AddTodo>(_onAddTodo);
    on<DeleteTodo>(_onDeleteTodo);
  }

  Future<void> _onFetchTodos(FetchTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todosData = await repository.fetchTodos();
      final todos = todosData.map((json) => Todo.fromJson(json)).toList();
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      await repository.addTodo(event.description);
      add(FetchTodos());
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      await repository.deleteTodo(event.id);
      add(FetchTodos());
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }
}
