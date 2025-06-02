import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatinapp/cubit/user_cubit.dart';

class OtherActivityPage extends StatefulWidget {
  const OtherActivityPage({super.key});

  @override
  State<OtherActivityPage> createState() => _OtherActivityPageState();
}

class _OtherActivityPageState extends State<OtherActivityPage> {
  int selectedIndex = 1;

  List<TextEditingController> controllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  List<String?> savedTexts = List.generate(3, (_) => null);
  List<bool> isDone = List.generate(3, (_) => false);
  int? activeIndex;

  final List<Color> borderColors = [
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.pink,
  ];

  void setActive(int index) {
    setState(() {
      activeIndex = index;
    });
  }

  void saveActivity() {
    if (activeIndex != null) {
      setState(() {
        savedTexts[activeIndex!] = controllers[activeIndex!].text;
        activeIndex = null;
      });
    }
  }

  void deleteActivity(int index) {
    setState(() {
      controllers[index].clear();
      savedTexts[index] = null;
      isDone[index] = false;
      if (activeIndex == index) activeIndex = null;
    });
  }

  double get progress {
    final filled =
        savedTexts.where((text) => text != null && text!.isNotEmpty).length;
    return filled / savedTexts.length;
  }

  void onNavTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Aktivitas Lainnya'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<UserCubit, Map<String, String?>>(
        builder: (context, userData) {
          final photoUrl = userData['photoUrl'];

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage:
                                      photoUrl != null
                                          ? NetworkImage(photoUrl)
                                          : null,
                                  radius: 20,
                                  child:
                                      photoUrl == null
                                          ? const Text(
                                            'N',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          )
                                          : null,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Aktivitas hari ini',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).round()}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 10,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Aktivitas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    ...List.generate(3, (index) {
                      final isActive = index == activeIndex;
                      final isFilled =
                          savedTexts[index] != null &&
                          savedTexts[index]!.isNotEmpty;

                      return GestureDetector(
                        onTap: () {
                          if (isFilled) {
                            setState(() {
                              isDone[index] = !isDone[index];
                            });
                          } else {
                            setActive(index);
                          }
                        },
                        child: Opacity(
                          opacity:
                              (activeIndex == null || isActive) ? 1.0 : 0.4,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: borderColors[index],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (!isDone[index] && isActive)
                                  Container(
                                    width: 16,
                                    height: 16,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade700,
                                        width: 2,
                                      ),
                                    ),
                                  )
                                else if (isDone[index])
                                  const Icon(Icons.check, color: Colors.blue),

                                Expanded(
                                  child:
                                      isActive
                                          ? TextField(
                                            controller: controllers[index],
                                            autofocus: true,
                                            decoration: const InputDecoration(
                                              hintText: 'Tambah Aktivitas',
                                              border: InputBorder.none,
                                              isDense: true,
                                            ),
                                          )
                                          : Text(
                                            savedTexts[index] ??
                                                'Tambah Aktivitas',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  isFilled
                                                      ? Colors.black
                                                      : Colors.grey,
                                            ),
                                          ),
                                ),

                                if (isActive)
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () => setActive(index),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 20,
                                        ),
                                        onPressed: () => deleteActivity(index),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Sudah selesai',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    ...List.generate(3, (index) {
                      if (!isDone[index]) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: borderColors[index],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                savedTexts[index] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              Positioned(
                bottom: 72,
                right: 24,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: FloatingActionButton(
                    onPressed: saveActivity,
                    backgroundColor: Colors.blue,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ), // <- di sini ubah
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
