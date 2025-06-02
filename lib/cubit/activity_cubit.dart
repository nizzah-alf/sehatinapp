import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatinapp/data/model/activity_model.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';

class ActivityCubit extends Cubit<List<Activity>> {
  final AuthRepository authRepository;

  ActivityCubit(this.authRepository) : super([]);

  Future<void> loadActivities() async {
    try {
      final todosData = await authRepository.fetchTodos();
      final list = todosData.map((e) => Activity.fromJson(e)).toList();
      emit(list);
    } catch (_) {
      emit([]);
    }
  }

  Future<void> toggleActivityDone(Activity activity) async {
    final newStatus = !activity.isDone;
    await authRepository.updateTodoStatus(activity.id, newStatus);
    final updatedList =
        state.map((a) {
          if (a.id == activity.id) {
            return Activity(
              id: a.id,
              description: a.description,
              isDone: newStatus,
              createdAt: a.createdAt,
            );
          }
          return a;
        }).toList();
    emit(updatedList);
  }
}
