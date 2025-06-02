import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sehatinapp/bloc/like/like_bloc.dart';
import 'package:sehatinapp/bloc/like/like_event.dart';
import 'package:sehatinapp/bloc/like/like_state.dart';


String getFullImageUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final cleanPath = path.startsWith('/') ? path : '/$path';
  return 'https://sehatin.site$cleanPath';
}

class ArtikelDetailPage extends StatefulWidget {
  final String title;
  final String desc;
  final String content;
  final String image;
  final String author;
  final String date;
  final int articleId;

  const ArtikelDetailPage({
    super.key,
    required this.title,
    required this.desc,
    required this.content,
    required this.image,
    required this.author,
    required this.date,
    required this.articleId,
  });

  @override
  State<ArtikelDetailPage> createState() => _ArtikelDetailPageState();
}

class _ArtikelDetailPageState extends State<ArtikelDetailPage> {
  bool _showScrollToTop = false;
  final ScrollController _scrollController = ScrollController();

  String _formatTanggal(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return rawDate;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_showScrollToTop) {
        setState(() {
          _showScrollToTop = true;
        });
      } else if (_scrollController.offset <= 100 && _showScrollToTop) {
        setState(() {
          _showScrollToTop = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = getFullImageUrl(widget.image);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Artikel Kesehatan',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
        ),
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 220,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 80),
                            );
                          },
                        )
                      : Container(
                          height: 220,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 80,
                          ),
                        ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(thickness: 1.5),
                const SizedBox(height: 12),
                Text(
                  widget.desc,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      const Divider(thickness: 1.2),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade700,
                                radius: 18,
                                child: Text(
                                  _getInitials(
                                    widget.author.isNotEmpty ? widget.author : 'U',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: 'Fredoka',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.author.isNotEmpty ? widget.author : 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      fontFamily: 'Fredoka',
                                    ),
                                  ),
                                  Text(
                                    _formatTanggal(
                                      widget.date.isNotEmpty ? widget.date : DateTime.now().toIso8601String(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontFamily: 'Fredoka',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          BlocBuilder<LikeBloc, LikeState>(
                            builder: (context, state) {
                              final isLiked = state.likedStatus[widget.articleId] ?? false;
                              final likeCount = state.likeCounts[widget.articleId] ?? 0;

                              return InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  context.read<LikeBloc>().add(ToggleLikeEvent(widget.articleId));
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: isLiked ? Colors.redAccent : Colors.grey,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$likeCount',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Fredoka',
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

                const SizedBox(height: 20),
              ],
            ),
          ),

          if (_showScrollToTop)
            Positioned(
              bottom: 100,
              right: 12,
              child: FloatingActionButton(
                backgroundColor: Colors.blueAccent,
                mini: true,
                shape: const CircleBorder(),
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                  );
                },
                child: const Icon(Icons.arrow_upward),
              ),
            ),
        ],
      ),
    );
  }
}
