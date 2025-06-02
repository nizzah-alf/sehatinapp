import 'package:flutter/material.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';
import 'package:sehatinapp/data/model/activity_model.dart';

class ActivityData extends ChangeNotifier {
  final AuthRepository authRepository = AuthRepository();

  List<Activity> _adminActivities = [];
  List<Activity> _userActivities = [];
  bool _isLoading = false;

  List<Activity> get activities => _adminActivities;
  List<Activity> get addedActivities => _userActivities;
  bool get isLoading => _isLoading;

  Future<void> loadActivities() async {
    _isLoading = true;
    notifyListeners();

    try {
      final todosData = await authRepository.fetchTodos();

      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(hours: 24));

      List<Activity> adminList = [];
      List<Activity> userList = [];

      for (var json in todosData) {
        final activity = Activity.fromJson(json);

        if (activity.userId == null) {
          adminList.add(activity);
        } else {
          final isExpired = activity.createdAt.isBefore(cutoff);
          final updatedActivity =
              isExpired ? activity.copyWith(isDone: false) : activity;

          if (!isExpired) {
            userList.add(updatedActivity);
          }
        }
      }

      _adminActivities = adminList;
      _userActivities = userList;
    } catch (e) {
      _adminActivities = [];
      _userActivities = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  double get progress {
    final all = [..._adminActivities, ..._userActivities];
    if (all.isEmpty) return 0;
    return all.where((a) => a.isDone).length / all.length;
  }

  Future<void> toggleActivityDone(Activity activity) async {
    final newStatus = !activity.isDone;
    try {
      await authRepository.updateTodoStatus(activity.id, newStatus);

      bool updated = false;

      _adminActivities =
          _adminActivities.map((a) {
            if (a.id == activity.id) {
              updated = true;
              return a.copyWith(isDone: newStatus);
            }
            return a;
          }).toList();

      if (!updated) {
        _userActivities =
            _userActivities.map((a) {
              if (a.id == activity.id) {
                return a.copyWith(isDone: newStatus);
              }
              return a;
            }).toList();
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addActivity(String description) async {
    try {
      await authRepository.addTodo(description);
      await loadActivities();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAddedActivity(int id, String newDesc) async {
    _userActivities =
        _userActivities.map((a) {
          if (a.id == id) {
            return a.copyWith(description: newDesc);
          }
          return a;
        }).toList();
    notifyListeners();
  }

  Future<void> deleteAddedActivity(int id) async {
    try {
      await authRepository.deleteTodo(id);
      _userActivities.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
