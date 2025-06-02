import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:sehatinapp/bloc/like/like_bloc.dart';
import 'package:sehatinapp/bloc/like/like_event.dart';
import 'package:sehatinapp/bloc/like/like_state.dart';
import 'package:sehatinapp/data/model/respone/artikel_response.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';
import 'artikelDetail.dart';


String getFullImageUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final cleanPath = path.startsWith('/') ? path : '/$path';
  return 'https://sehatin.site$cleanPath';
}

class ArtikelPage extends StatefulWidget {
  const ArtikelPage({super.key});

  @override
  State<ArtikelPage> createState() => _ArtikelPageState();
}

class _ArtikelPageState extends State<ArtikelPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> categories = [
    "Kesehatan",
    "Gaya Hidup",
    "Nutrisi",
    "Olahraga",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    context.read<LikeBloc>().add(LoadLikedArticlesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTab(int index) {
    final bool isSelected = _tabController.index == index;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade400,
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          categories[index],
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = AuthRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Artikel Kesehatan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Colors.transparent, width: 0),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.only(left: 2),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: const BoxDecoration(),
              indicatorWeight: 0,
              labelPadding: EdgeInsets.zero,
              tabs: List.generate(
                categories.length,
                (index) => _buildTab(index),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          categories.length,
          (index) => ArtikelListView(categoryId: index + 1),
        ),
      ),
    );
  }
}

class ArtikelListView extends StatelessWidget {
  final int categoryId;

  const ArtikelListView({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final repository = AuthRepository();

    return FutureBuilder<String?>(
      future: repository.getToken(),
      builder: (context, tokenSnapshot) {
        if (tokenSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (tokenSnapshot.hasError || tokenSnapshot.data == null) {
          return Center(
            child: Text('Gagal mengambil token: ${tokenSnapshot.error}'),
          );
        }

        final token = tokenSnapshot.data!;

        return FutureBuilder<List<Artikel>>(
          future: repository.fetchArticles(token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Gagal mengambil artikel: ${snapshot.error}'),
              );
            }

            final articles = snapshot.data!.where((article) => article.categoryId == categoryId).toList();

            if (articles.isEmpty) {
              return const Center(
                child: Text('Tidak ada artikel di kategori ini.'),
              );
            }

            return BlocBuilder<LikeBloc, LikeState>(
              builder: (context, likeState) {
                return ListView.builder(
                  padding: const EdgeInsets.only(left: 12, right: 16, top: 16, bottom: 16),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    final isLiked = likeState.likedStatus[article.id] ?? false;
                    final likeCount = likeState.likeCounts[article.id] ?? 0;

                    final imageUrl = getFullImageUrl(article.image ?? '');

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArtikelDetailPage(
                              title: article.title,
                              desc: article.isi,
                              content: article.isi,
                              image: imageUrl,
                              author: 'Tim Sehatin',
                              date: article.createdAt ?? '',
                              articleId: article.id,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.image_not_supported),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image_not_supported),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        article.isi,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    context.read<LikeBloc>().add(ToggleLikeEvent(article.id));
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                        size: 16,
                                        color: isLiked ? Colors.red : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        likeCount.toString(),
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
