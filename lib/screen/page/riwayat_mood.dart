import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';
import 'package:sehatinapp/data/datasource/mood_repo.dart';
import 'package:sehatinapp/screen/page/mood_detail.dart';
import 'package:sehatinapp/screen/page/moodEntery.dart';

class RiwayatMoodPage extends StatefulWidget {
  const RiwayatMoodPage({super.key});

  @override
  _RiwayatMoodPageState createState() => _RiwayatMoodPageState();
}

class _RiwayatMoodPageState extends State<RiwayatMoodPage> {
  List<Map<String, dynamic>> riwayatMood = [];

  late MoodRepository moodRepository;
  late AuthRepository authRepository;

  bool isLoading = true;
  String? errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ambil AuthRepository dari Provider supaya konsisten & token valid
    authRepository = Provider.of<AuthRepository>(context, listen: false);

    // Pastikan baseUrl ada "/api" di belakang kalau endpoint memang seperti itu
    moodRepository = MoodRepository(
      baseUrl: '${authRepository.baseUrl}/api',
      authRepository: authRepository,
    );

    _loadMood();
  }

  Future<void> _loadMood() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final moodDataList = await moodRepository.getMood();
      print('Raw mood data from API: $moodDataList'); // Debug print

      setState(() {
        riwayatMood = moodDataList.map<Map<String, dynamic>>((e) {
          return {
            'tanggal': e['created_at'] ?? '',
            'mood': e['image'] ?? '',
            'tentang': e['kategori'] ?? '',
            'cerita': e['catatan'] ?? '',
          };
        }).toList();

        riwayatMood.sort((a, b) {
          DateTime dateA = DateTime.parse(a['tanggal']);
          DateTime dateB = DateTime.parse(b['tanggal']);
          return dateB.compareTo(dateA);
        });
      });
    } catch (e) {
      print('Error loading mood data: $e');
      setState(() {
        errorMessage = 'Gagal memuat data mood: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => _buildMoodCard(item)).toList(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMoodCard(Map<String, dynamic> moodData) {
    DateTime tgl = DateTime.parse(moodData['tanggal']).toLocal();
    String formattedDate = DateFormat('d MMMM', 'id_ID').format(tgl);

    Color sideColor;
    String mood = moodData['mood']?.toLowerCase() ?? '';

    if (mood.contains('senang')) {
      sideColor = const Color(0xFFB2D3FA);
    } else if (mood.contains('bahagia')) {
      sideColor = const Color(0xFFF2C4C4);
    } else if (mood.contains('kesal')) {
      sideColor = const Color(0xFFC93636);
    } else if (mood.contains('sedih')) {
      sideColor = const Color(0xFFD7BC8D);
    } else if (mood.contains('bingung')) {
      sideColor = const Color(0xFF45413C);
    } else if (mood.contains('netral')) {
      sideColor = const Color(0xFFA9E0C5);
    } else {
      sideColor = Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (_, controller) => SingleChildScrollView(
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        moodData['mood'] ?? 'Mood tidak diketahui',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 16,
                  child: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
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
    DateTime today = DateTime.now();
    DateTime kemarin = today.subtract(const Duration(days: 1));

    List<Map<String, dynamic>> hariIni = [];
    List<Map<String, dynamic>> kemarinList = [];
    List<Map<String, dynamic>> mingguLalu = [];

    for (var item in riwayatMood) {
      if (item['tanggal'] == null || item['tanggal'] == '') continue;

      DateTime tgl = DateTime.parse(item['tanggal']).toLocal();

      if (_isSameDay(tgl, today)) {
        hariIni.add(item);
      } else if (_isSameDay(tgl, kemarin)) {
        kemarinList.add(item);
      } else {
        mingguLalu.add(item);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Mood'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : riwayatMood.isEmpty
                  ? const Center(child: Text('Belum ada data mood'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (hariIni.isNotEmpty) _buildSection('Hari ini', hariIni),
                        if (kemarinList.isNotEmpty)
                          _buildSection('Kemarin', kemarinList),
                        if (mingguLalu.isNotEmpty)
                          _buildSection('Minggu lalu', mingguLalu),
                      ],
                    ),
    );
  }
}
