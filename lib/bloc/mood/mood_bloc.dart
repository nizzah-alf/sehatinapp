import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatinapp/screen/page/moodEntery.dart';
import 'mood_event.dart';
import 'mood_state.dart';
import '../../data/datasource/mood_repo.dart';

class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final MoodRepository repository;

  MoodBloc({required this.repository}) : super(MoodInitial()) {
    on<SubmitMoodEvent>((event, emit) async {
      emit(MoodLoading());
      try {
        await repository.submitMood(
          kategori: event.kategori,
          image: event.image,
          catatan: event.catatan,
        );
        emit(MoodSuccess());
      } catch (e) {
        emit(MoodFailure(e.toString()));
      }
    });

    on<FetchMoodEvent>((event, emit) async {
      emit(MoodLoading());
      try {
        final moods = await repository.getMood(date: event.date);
        final moodEntries = moods.map((json) => MoodEntry.fromJson(json)).toList();
        emit(MoodLoaded(moodEntries));
      } catch (e) {
        emit(MoodFailure(e.toString()));
      }
    });
  }
}
