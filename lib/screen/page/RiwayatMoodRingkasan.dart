import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sehatinapp/screen/page/moodEntery.dart';
import 'package:sehatinapp/screen/page/mood_detail.dart';

class RiwayatMoodRingkasan extends StatelessWidget {
  final List<MoodEntry> moodList;

  const RiwayatMoodRingkasan({Key? key, required this.moodList})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<MoodEntry> limited =
        moodList.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Mood Terbaru',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...limited.map((mood) {
          final tgl = DateTime.tryParse(mood.tanggal);
          final formatted =
              tgl != null
                  ? DateFormat('d MMMM', 'id_ID').format(tgl)
                  : 'Tanggal tidak valid';

          return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder:
                    (context) => DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.6,
                      minChildSize: 0.4,
                      maxChildSize: 0.95,
                      builder:
                          (_, controller) => SingleChildScrollView(
                            controller: controller,
                            child: MoodDetailContent(mood: mood),
                          ),
                    ),
              );
            },

            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.mood, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatted,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(mood.tentang),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
