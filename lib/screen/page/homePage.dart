import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:sehatinapp/bloc/artikel/artikel_bloc.dart';
import 'package:sehatinapp/bloc/artikel/artikel_event.dart';
import 'package:sehatinapp/bloc/artikel/artikel_state.dart';
import 'package:sehatinapp/bloc/like/like_bloc.dart';
import 'package:sehatinapp/bloc/like/like_event.dart';
import 'package:sehatinapp/bloc/like/like_state.dart';

import 'package:sehatinapp/data/datasource/auth_repo.dart';
import 'package:sehatinapp/data/datasource/mood_repo.dart';
import 'package:sehatinapp/data/model/activity_model.dart';
import 'package:sehatinapp/screen/page/artikelDetail.dart';
import 'package:sehatinapp/screen/page/activityPage.dart';
import 'package:sehatinapp/screen/page/artikelPage.dart';
import 'package:sehatinapp/screen/page/isi_mood.dart';
import 'package:sehatinapp/screen/page/mood_kalender.dart';
import 'package:sehatinapp/screen/page/profilePage.dart';

import 'package:sehatinapp/screen/page/activity_data.dart';
import 'package:sehatinapp/cubit/user_cubit.dart';
import 'package:sehatinapp/screen/page/riwayat_mood.dart';

class HomePage extends StatefulWidget {
  final String? initialUserName;

  const HomePage({super.key, this.initialUserName});

  @override
  State<HomePage> createState() => _HomePageState();
}

String getFullImageUrl(String path) {
  if (path.isEmpty) return '';
  return 'https://sehatin.rm-rf.web.id/storage/$path';
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final AuthRepository authRepository;
  late final ArtikelBloc artikelBloc;
  late final MoodRepository moodRepository;

  List<Map<String, dynamic>> todayMood = [];

  @override
  void initState() {
    super.initState();

    authRepository = AuthRepository();

    artikelBloc = ArtikelBloc(authRepository);
    artikelBloc.add(FetchArticles());

    moodRepository = MoodRepository(
      baseUrl: 'http://sehatin.site/api',
      authRepository: authRepository,
    );

    Future.microtask(() {
      Provider.of<ActivityData>(context, listen: false).loadActivities();
      context.read<UserCubit>().loadUserData();
    });

    _loadTodayMood();
  }

  Future<void> _loadTodayMood() async {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      final moods = await moodRepository.getMood(date: todayStr);
      if (!mounted) return;
      setState(() {
        todayMood =
            moods
                .map(
                  (m) => {
                    'tanggal': m['created_at'],
                    'mood': m['image'],
                    'tentang': m['kategori'],
                    'cerita': m['catatan'],
                  },
                )
                .toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        todayMood = [];
      });
    }
  }

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void dispose() {
    artikelBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ArtikelBloc>.value(
      value: artikelBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: _buildPage(_selectedIndex)),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            top: 8,
          ),
          child: PhysicalModel(
            color: Colors.transparent,
            elevation: 8,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(30),
              ),
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
                  _buildNavItem(
                    icon: Icons.event_note,
                    label: 'Jadwal',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.sentiment_satisfied_alt,
                    label: 'Mood',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.article,
                    label: 'Artikel',
                    index: 3,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                    index: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Icon(
                icon,
                color: selected ? Colors.white : Colors.white70,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildHomePageContent();
      case 1:
        return const ActivityPage();
      case 2:
        return MoodCalendarPage();
      case 3:
        return const ArtikelPage();
      case 4:
        return const ProfilePage();
      default:
        return _buildHomePageContent();
    }
  }

  Widget _buildHomePageContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 30,
              bottom: 80,
            ),
            decoration: const BoxDecoration(color: Color(0xFF3B82F6)),
            child: BlocBuilder<UserCubit, Map<String, String?>>(
              builder: (context, userData) {
                final Name = userData['name'] ?? 'Pengguna';
                final photoUrl = userData['photoUrl'] ?? '';

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hai, $Name!",
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Siap jadi sehat hari ini?",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        ).then((_) => context.read<UserCubit>().loadUserData());
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            (photoUrl.isNotEmpty)
                                ? NetworkImage(photoUrl)
                                : null,
                        child:
                            (photoUrl.isEmpty)
                                ? Text(
                                  Name.isNotEmpty ? Name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                  ),
                                )
                                : null,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/poster.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 0),

          //MOOD TITLE 
          _buildMoodTitleHeader(),
          const SizedBox(height: 8),

          //MOOD REMIND
          _buildMoodReminderOrList(),

          const SizedBox(height: 20),

          _buildAktivitasSection(),
          const SizedBox(height: 8),
          _buildArtikelViralSection(),
          const SizedBox(height: 12),
          _buildLainnyaHeader(),
          const SizedBox(height: 10),
          _buildLainnyaSectionWithBloc(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMoodTitleHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Mood hari ini',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMoodReminderOrList() {
    if (todayMood.isEmpty) {
      return _buildMoodBelumIsiCard();
    } else {
      return _buildMoodSudahTercatatCard();
    }
  }

  Widget _buildMoodBelumIsiCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IsiMoodPage(moodRepository: moodRepository),
          ),
        ).then((_) {
          _loadTodayMood();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black54, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFB6CDFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/senang.png',
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kamu belum mencatat suasana hati hari ini. Yuk, luangkan satu menit untuk menuliskannya',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    IsiMoodPage(moodRepository: moodRepository),
                          ),
                        ).then((_) {
                          _loadTodayMood();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Isi mood sekarang',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSudahTercatatCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black54, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFB6CDFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/senang.png',
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mood hari ini sudah tercatat. Semoga harimu menyenangkan!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RiwayatMoodPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Lihat Riwayat Mood',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAktivitasSection() {
    return Consumer<ActivityData>(
      builder: (context, activityData, child) {
        final activities = activityData.activities;
        final limitedActivities = activities.take(4).toList();

        if (activities.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Text("Belum ada aktivitas."),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aktivitas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ActivityPage(),
                          ),
                        ),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                children:
                    limitedActivities.map(_buildActivityTileHome).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTileHome(Activity activity) {
    final isUserActivity = activity.userId != null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: activity.isDone ? Colors.grey[300] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: GestureDetector(
          onTap: () {
            context.read<ActivityData>().toggleActivityDone(activity);
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 2),
              color: activity.isDone ? Colors.grey : Colors.transparent,
            ),
            child:
                activity.isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
          ),
        ),
        title: Text(
          activity.description,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: null,
            color:
                activity.isDone
                    ? Colors.grey
                    : (isUserActivity ? Colors.grey[800] : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildArtikelViralSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: BlocBuilder<ArtikelBloc, ArtikelState>(
        builder: (context, state) {
          if (state is ArtikelLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ArtikelLoaded) {
            if (state.artikels.isEmpty) {
              return const Center(child: Text('Belum ada artikel viral.'));
            }

            final likeState = context.read<LikeBloc>().state;
            final sortedArticles = [...state.artikels];
            sortedArticles.sort((a, b) {
              final aLikes = likeState.likeCounts[a.id] ?? 0;
              final bLikes = likeState.likeCounts[b.id] ?? 0;
              return bLikes.compareTo(aLikes);
            });

            final viralArticles = sortedArticles.take(4).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Artikel Viral',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 215,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: viralArticles.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final artikel = viralArticles[index];
                      final imageUrl = getFullImageUrl(artikel.image ?? '');

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ArtikelDetailPage(
                                    title: artikel.title,
                                    desc: artikel.isi,
                                    content: artikel.isi,
                                    image: "/storage/${artikel.image ?? ''}",
                                    author: 'Tim Sehatin',
                                    date: artikel.createdAt ?? '',
                                    articleId: artikel.id,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          width: 270,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child:
                                    imageUrl.isNotEmpty
                                        ? Image.network(
                                          imageUrl,
                                          width: 270,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (
                                                context,
                                                error,
                                                stackTrace,
                                              ) => Image.asset(
                                                'assets/images/image_placeholder.png',
                                                width: 270,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              ),
                                        )
                                        : Image.asset(
                                          'assets/images/image_placeholder.png',
                                          width: 270,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      artikel.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        BlocBuilder<LikeBloc, LikeState>(
                                          builder: (context, likeState) {
                                            final isLiked =
                                                likeState.likedStatus[artikel
                                                    .id] ??
                                                false;
                                            final likeCount =
                                                likeState.likeCounts[artikel
                                                    .id] ??
                                                0;

                                            return InkWell(
                                              onTap: () {
                                                context.read<LikeBloc>().add(
                                                  ToggleLikeEvent(artikel.id),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isLiked
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    size: 16,
                                                    color:
                                                        isLiked
                                                            ? Colors.red
                                                            : Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    likeCount.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is ArtikelError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildLainnyaHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Lainnya',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ArtikelPage()),
                ),
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLainnyaSectionWithBloc() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<ArtikelBloc, ArtikelState>(
        builder: (context, state) {
          if (state is ArtikelLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ArtikelLoaded) {
            if (state.artikels.isEmpty) {
              return const Center(child: Text('Belum ada artikel.'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  state.artikels.take(4).map((artikel) {
                    final imageUrl = getFullImageUrl(artikel.image ?? '');

                    return GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ArtikelDetailPage(
                                    title: artikel.title,
                                    desc: artikel.isi,
                                    content: artikel.isi,
                                    image: "/storage/${artikel.image ?? ''}",
                                    author: 'Tim Sehatin',
                                    date: artikel.createdAt ?? '',
                                    articleId: artikel.id,
                                  ),
                            ),
                          ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  imageUrl.isNotEmpty
                                      ? Image.network(
                                        imageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => Image.asset(
                                              'assets/images/image_placeholder.png',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                      )
                                      : Image.asset(
                                        'assets/images/image_placeholder.png',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    artikel.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    artikel.isi.length > 20
                                        ? '${artikel.isi.substring(0, 20)}...'
                                        : artikel.isi,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      BlocBuilder<LikeBloc, LikeState>(
                                        builder: (context, likeState) {
                                          final isLiked =
                                              likeState.likedStatus[artikel
                                                  .id] ??
                                              false;
                                          final likeCount =
                                              likeState.likeCounts[artikel
                                                  .id] ??
                                              0;

                                          return InkWell(
                                            onTap: () {
                                              context.read<LikeBloc>().add(
                                                ToggleLikeEvent(artikel.id),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isLiked
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  size: 16,
                                                  color:
                                                      isLiked
                                                          ? Colors.red
                                                          : Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  likeCount.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            );
          } else if (state is ArtikelError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Container();
        },
      ),
    );
  }
}
