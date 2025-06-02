class MoodEntry {
  final String tanggal;
  final String mood;
  final String tentang;
  final String cerita;

  MoodEntry({
    required this.tanggal,
    required this.mood,
    required this.tentang,
    required this.cerita,
  });
  Map<String, dynamic> toJson() => {
        'tanggal': tanggal,
        'mood': mood,
        'tentang': tentang,
        'cerita': cerita,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        tanggal: json['tanggal']?.toString() ?? '',
        mood: json['mood']?.toString() ?? '',
        tentang: json['tentang']?.toString() ?? '',
        cerita: json['cerita']?.toString() ?? '',
      );

  @override
  String toString() {
    return 'MoodEntry(tanggal: $tanggal, mood: $mood, tentang: $tentang, cerita: $cerita)';
  }
}
