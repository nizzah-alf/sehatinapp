import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sehatinapp/screen/page/moodEntery.dart';

class MoodDetailContent extends StatelessWidget {
  final MoodEntry mood;

  const MoodDetailContent({Key? key, required this.mood}) : super(key: key);

  Color getMoodColor(String mood) {
    String m = mood.toLowerCase();
    if (m.contains('senang')) return const Color(0xFFB2D3FA);
    if (m.contains('bahagia')) return const Color(0xFFF2C4C4);
    if (m.contains('kesal')) return const Color(0xFFC93636);
    if (m.contains('sedih')) return const Color(0xFFD7BC8D);
    if (m.contains('bingung')) return const Color(0xFF45413C);
    if (m.contains('netral')) return const Color(0xFFA9E0C5);
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    DateTime? tgl;
    try {
      tgl = DateTime.parse(mood.tanggal);
    } catch (_) {
      try {
        tgl = DateFormat('dd/MM/yyyy').parseStrict(mood.tanggal);
      } catch (_) {
        tgl = null;
      }
    }

    String formattedDate = tgl != null
        ? DateFormat('d MMMM', 'id_ID').format(tgl)
        : 'Tanggal tidak valid';

    final moodColor = getMoodColor(mood.mood);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/${mood.mood.toLowerCase()}.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported, size: 30),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mood.mood.toLowerCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Tentang',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              mood.tentang,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Apa yang terjadi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: moodColor.withOpacity(0.2), 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: moodColor.withOpacity(0.4)),
            ),
            child: Text(
              mood.cerita,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
