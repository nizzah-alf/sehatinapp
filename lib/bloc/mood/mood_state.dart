import 'package:sehatinapp/screen/page/moodEntery.dart';

abstract class MoodState {}

class MoodInitial extends MoodState {}

class MoodLoading extends MoodState {}

class MoodSuccess extends MoodState {}

class MoodFailure extends MoodState {
  final String error;
  MoodFailure(this.error);
}

class MoodLoaded extends MoodState {
  final List<MoodEntry> moods;
  MoodLoaded(this.moods);
}
