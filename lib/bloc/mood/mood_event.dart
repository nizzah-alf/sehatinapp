abstract class MoodEvent {}

class SubmitMoodEvent extends MoodEvent {
  final String kategori;
  final String image;
  final String catatan;

  SubmitMoodEvent({
    required this.kategori,
    required this.image,
    required this.catatan,
  });
}

class FetchMoodEvent extends MoodEvent {
  final String? date;
  FetchMoodEvent({this.date});
}
