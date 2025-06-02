import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';
import 'package:sehatinapp/data/datasource/mood_repo.dart';
import 'package:sehatinapp/screen/page/isi_mood.dart';
import 'package:sehatinapp/screen/page/mood_detail.dart';
import 'package:sehatinapp/screen/page/moodEntery.dart';

class MoodCalendarPage extends StatefulWidget {
  @override
  _MoodCalendarPageState createState() => _MoodCalendarPageState();
}

class _MoodCalendarPageState extends State<MoodCalendarPage> {
  late String selectedMonth;
  late int selectedYear;
  late int selectedDate;

  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final Map<String, int> daysInMonth = {
    'Januari': 31,
    'Februari': 28,
    'Maret': 31,
    'April': 30,
    'Mei': 31,
    'Juni': 30,
    'Juli': 31,
    'Agustus': 31,
    'September': 30,
    'Oktober': 31,
    'November': 30,
    'Desember': 31,
  };

  List<MoodEntry> moodList = [];

  List<Map<String, dynamic>> hariIniList = [];
  List<Map<String, dynamic>> kemarinList = [];
  List<Map<String, dynamic>> mingguLaluList = [];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    selectedYear = now.year;
    selectedMonth = months[now.month - 1];
    selectedDate = now.day;
    fetchRecentMoods();
  }

  void fetchRecentMoods() async {
    final authRepository = Provider.of<AuthRepository>(context, listen: false);
    final moodRepository = MoodRepository(
      baseUrl: authRepository.baseUrl,
      authRepository: authRepository,
    );

    try {
      final fetched = await moodRepository.getMood();
      List<MoodEntry> result =
          fetched.map<MoodEntry>((e) {
            return MoodEntry(
              tanggal: e['created_at'] ?? '',
              mood: e['image'] ?? '',
              tentang: e['kategori'] ?? '',
              cerita: e['catatan'] ?? '',
            );
          }).toList();

      result.sort(
        (a, b) =>
            DateTime.parse(b.tanggal).compareTo(DateTime.parse(a.tanggal)),
      );

      setState(() {
        moodList = result;
        _groupMoodByDate();
      });
    } catch (e) {
      print("Error fetching moods: $e");
    }
  }

  void _groupMoodByDate() {
    hariIniList.clear();
    kemarinList.clear();
    mingguLaluList.clear();

    DateTime today = DateTime.now();
    DateTime kemarin = today.subtract(Duration(days: 1));
    DateTime mingguLalu = today.subtract(Duration(days: 7));

    for (var mood in moodList) {
      DateTime? tgl = _parseDate(mood.tanggal);
      if (tgl == null) continue;

      if (_isSameDay(tgl, today)) {
        hariIniList.add({
          'tanggal': mood.tanggal,
          'mood': mood.mood,
          'tentang': mood.tentang,
          'cerita': mood.cerita,
        });
      } else if (_isSameDay(tgl, kemarin)) {
        kemarinList.add({
          'tanggal': mood.tanggal,
          'mood': mood.mood,
          'tentang': mood.tentang,
          'cerita': mood.cerita,
        });
      } else if (tgl.isAfter(mingguLalu)) {
        mingguLaluList.add({
          'tanggal': mood.tanggal,
          'mood': mood.mood,
          'tentang': mood.tentang,
          'cerita': mood.cerita,
        });
      }
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

  DateTime? _parseDate(String input) {
    try {
      return DateTime.parse(input);
    } catch (_) {
      try {
        return DateFormat('dd/MM/yyyy').parseStrict(input);
      } catch (_) {
        return null;
      }
    }
  }

  Color _getMoodColor(String mood) {
    String m = mood.toLowerCase();
    if (m.contains('senang')) return Color(0xFFB2D3FA);
    if (m.contains('bahagia')) return Color(0xFFF2C4C4);
    if (m.contains('kesal')) return Color(0xFFC93636);
    if (m.contains('sedih')) return Color(0xFFD7BC8D);
    if (m.contains('bingung')) return Color(0xFF45413C);
    if (m.contains('netral')) return Color(0xFFA9E0C5);
    return Colors.grey.shade300;
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> moods) {
    if (moods.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ...moods.map((moodData) => _buildMoodCard(moodData)).toList(),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMoodCard(Map<String, dynamic> moodData) {
    DateTime tgl = DateTime.parse(moodData['tanggal']);
    String formattedDate = DateFormat('d MMMM', 'id_ID').format(tgl);

    Color sideColor;
    String mood = moodData['mood']?.toLowerCase() ?? '';

    if (mood.contains('senang')) {
      sideColor = Color(0xFFB2D3FA);
    } else if (mood.contains('bahagia')) {
      sideColor = Color(0xFFF2C4C4);
    } else if (mood.contains('kesal')) {
      sideColor = Color(0xFFC93636);
    } else if (mood.contains('sedih')) {
      sideColor = Color(0xFFD7BC8D);
    } else if (mood.contains('bingung')) {
      sideColor = Color(0xFF45413C);
    } else if (mood.contains('netral')) {
      sideColor = Color(0xFFA9E0C5);
    } else {
      sideColor = Colors.grey.shade300;
    }

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
                      child: MoodDetailContent(
                        mood: MoodEntry(
                          tanggal: moodData['tanggal'] ?? '',
                          mood: moodData['mood'] ?? '',
                          tentang: moodData['tentang'] ?? '',
                          cerita: moodData['cerita'] ?? '',
                        ),
                      ),
                    ),
              ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 90,
                decoration: BoxDecoration(
                  color: sideColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        moodData['mood'] ?? 'Mood tidak diketahui',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 16,
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalDays = daysInMonth[selectedMonth]!;
    DateTime now = DateTime.now();
    int todayDate = now.day;
    String todayMonth = months[now.month - 1];
    int todayYear = now.year;

    final authRepository = Provider.of<AuthRepository>(context, listen: false);
    final moodRepository = MoodRepository(
      baseUrl: authRepository.baseUrl,
      authRepository: authRepository,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Mood Harian',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Kalender ku',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$selectedYear', style: TextStyle(fontSize: 18)),
                  Container(
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedMonth = newValue!;
                            selectedDate = 1;
                          });
                        },
                        items:
                            months
                                .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white),
                child: Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(totalDays, (index) {
                      int day = index + 1;
                      bool isSelected = selectedDate == day;
                      bool isToday =
                          (day == todayDate &&
                              selectedMonth == todayMonth &&
                              selectedYear == todayYear);

                      Color bgColor =
                          isSelected
                              ? Colors.blue
                              : isToday
                              ? Colors.blue.withOpacity(0.4)
                              : Colors.white;
                      Color textColor =
                          (isSelected || isToday) ? Colors.white : Colors.black;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = day;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: bgColor,
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                IsiMoodPage(moodRepository: moodRepository),
                      ),
                    ).then((_) => fetchRecentMoods());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Mood Baru',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Mood',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/riwayatMoodpage');
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),

              SizedBox(height: 15),

              if (hariIniList.isNotEmpty)
                _buildSection('Hari ini', hariIniList.take(4).toList()),
              if (kemarinList.isNotEmpty)
                _buildSection('Kemarin', kemarinList.take(4).toList()),
              if (mingguLaluList.isNotEmpty)
                _buildSection('Minggu lalu', mingguLaluList.take(4).toList()),
            ],
          ),
        ),
      ),
    );
  }
}
