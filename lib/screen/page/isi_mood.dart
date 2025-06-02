import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/mood/mood_bloc.dart';
import '../../bloc/mood/mood_event.dart';
import '../../bloc/mood/mood_state.dart';
import '../../data/datasource/mood_repo.dart';
import 'riwayat_mood.dart';

class IsiMoodPage extends StatefulWidget {
  final MoodRepository moodRepository;

  const IsiMoodPage({Key? key, required this.moodRepository}) : super(key: key);

  @override
  _IsiMoodPageState createState() => _IsiMoodPageState();
}

class _IsiMoodPageState extends State<IsiMoodPage> {
  String? selectedMood;
  String? selectedCategory;
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> moods = [
    {'label': 'senang', 'image': 'senang.png'},
    {'label': 'bahagia', 'image': 'bahagia.png'},
    {'label': 'kesal', 'image': 'kesal.png'},
    {'label': 'sedih', 'image': 'sedih.png'},
    {'label': 'bingung', 'image': 'bingung.png'},
    {'label': 'netral', 'image': 'netral.png'},
  ];

  final List<String> moodCategories = [
    'kerjaan',
    'keluarga',
    'pasangan',
    'teman',
    'sekolah',
    'kesehatan',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MoodBloc(repository: widget.moodRepository),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9F9),
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.black,
          title: const Text(
            'Mood Harian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<MoodBloc, MoodState>(
          listener: (context, state) {
            if (state is MoodSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mood berhasil disimpan!')),
              );

              Future.delayed(const Duration(milliseconds: 800), () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) =>  RiwayatMoodPage()),
                );
              });
            } else if (state is MoodFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal simpan mood: ${state.error}')),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Catat suasana hatimu setiap hari untuk\nrefleksi diri dan keseimbangan emosi',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Mood hari ini',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: moods.map((mood) {
                    bool isSelected = selectedMood == mood['label'];
                    return GestureDetector(
                      onTap: () => setState(() => selectedMood = mood['label']),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.black,
                                        width: 3,
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Image.asset(
                                'assets/images/${mood['image']}',
                                height: 70,
                                width: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mood['label']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pilih mood',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: moodCategories.map((category) {
                    bool isSelectedCategory = selectedCategory == category;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = category),
                      child: Chip(
                        label: Text(category),
                        backgroundColor:
                            isSelectedCategory ? Colors.blue : Colors.white,
                        side: const BorderSide(color: Colors.black),
                        labelStyle: TextStyle(
                          color:
                              isSelectedCategory ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Catatan Mood',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Tulis catatan mood kamu...',
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                  minLines: 5,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 32),
                BlocBuilder<MoodBloc, MoodState>(
                  builder: (context, state) {
                    final isLoading = state is MoodLoading;
                    return ElevatedButton(
                      onPressed: isLoading ||
                              selectedMood == null ||
                              selectedCategory == null
                          ? null
                          : () => context.read<MoodBloc>().add(
                                SubmitMoodEvent(
                                  kategori: selectedCategory!,
                                  image: selectedMood!,
                                  catatan: _controller.text,
                                ),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLoading ? Colors.grey : Colors.blue,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Simpan mood'),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../bloc/mood/mood_bloc.dart';
// import '../../bloc/mood/mood_event.dart';
// import '../../bloc/mood/mood_state.dart';
// import '../../data/datasource/mood_repo.dart';
// import 'riwayat_mood.dart';

// class IsiMoodPage extends StatefulWidget {
//   final MoodRepository moodRepository;

//   const IsiMoodPage({Key? key, required this.moodRepository}) : super(key: key);

//   @override
//   _IsiMoodPageState createState() => _IsiMoodPageState();
// }

// class _IsiMoodPageState extends State<IsiMoodPage> {
//   String? selectedMood;
//   String? selectedCategory;
//   final TextEditingController _controller = TextEditingController();

//   final List<Map<String, String>> moods = [
//     {'label': 'senang', 'image': 'senang.png'},
//     {'label': 'bahagia', 'image': 'bahagia.png'},
//     {'label': 'kesal', 'image': 'kesal.png'},
//     {'label': 'sedih', 'image': 'sedih.png'},
//     {'label': 'bingung', 'image': 'bingung.png'},
//     {'label': 'netral', 'image': 'netral.png'},
//   ];

//   final List<String> moodCategories = [
//     'kerjaan',
//     'keluarga',
//     'pasangan',
//     'teman',
//     'sekolah',
//     'kesehatan',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => MoodBloc(repository: widget.moodRepository),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF9F9F9),
//         appBar: AppBar(
//           backgroundColor: const Color(0xFFF9F9F9),
//           elevation: 0,
//           centerTitle: true,
//           foregroundColor: Colors.black,
//           title: const Text(
//             'Mood Harian',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.black,
//             ),
//           ),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         body: BlocListener<MoodBloc, MoodState>(
//           listener: (context, state) {
//             if (state is MoodSuccess) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Mood berhasil disimpan!')),
//               );

//               Future.delayed(const Duration(milliseconds: 800), () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => RiwayatMoodPage()),
//                 );
//               });
//             } else if (state is MoodFailure) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Gagal simpan mood: ${state.error}')),
//               );
//             }
//           },
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 30),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Catat suasana hatimu setiap hari untuk\nrefleksi diri dan keseimbangan emosi',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.black,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 const Text(
//                   'Mood hari ini',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 20),
//                 GridView.count(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   children:
//                       moods.map((mood) {
//                         bool isSelected = selectedMood == mood['label'];
//                         return GestureDetector(
//                           onTap:
//                               () =>
//                                   setState(() => selectedMood = mood['label']),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min, 
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(16),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     border:
//                                         isSelected
//                                             ? Border.all(
//                                               color: Colors.black,
//                                               width: 3,
//                                             )
//                                             : null,
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   child: Image.asset(
//                                     'assets/images/${mood['image']}',
//                                     height: 70,
//                                     width: 72,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 mood['label']!,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                 ),

//                 const SizedBox(height: 24),

//                 const Text(
//                   'Pilih mood',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 8),

//                 Wrap(
//                   spacing: 8,
//                   children:
//                       moodCategories.map((category) {
//                         bool isSelectedCategory = selectedCategory == category;
//                         return GestureDetector(
//                           onTap:
//                               () => setState(() => selectedCategory = category),
//                           child: Chip(
//                             label: Text(category),
//                             backgroundColor:
//                                 isSelectedCategory ? Colors.blue : Colors.white,
//                             side: const BorderSide(color: Colors.black),
//                             labelStyle: TextStyle(
//                               color:
//                                   isSelectedCategory
//                                       ? Colors.white
//                                       : Colors.black,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                 ),

//                 const SizedBox(height: 24),

//                 const Text(
//                   'Catatan Mood',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 8),

//                 TextField(
//                   controller: _controller,
//                   decoration: InputDecoration(
//                     hintText: 'Tulis catatan mood kamu...',
//                     fillColor: Colors.white,
//                     filled: true,
//                     contentPadding: const EdgeInsets.all(16),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(
//                         color: Colors.blue,
//                         width: 1.5,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(
//                         color: Colors.blue,
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                   minLines: 5,
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                 ),

//                 const SizedBox(height: 32),

//                 BlocBuilder<MoodBloc, MoodState>(
//                   builder: (context, state) {
//                     final isLoading = state is MoodLoading;
//                     return ElevatedButton(
//                       onPressed:
//                           isLoading ||
//                                   selectedMood == null ||
//                                   selectedCategory == null
//                               ? null
//                               : () => context.read<MoodBloc>().add(
//                                 SubmitMoodEvent(
//                                   kategori: selectedCategory!,
//                                   image: selectedMood!,
//                                   catatan: _controller.text,
//                                 ),
//                               ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: isLoading ? Colors.grey : Colors.blue,
//                         minimumSize: const Size.fromHeight(48),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child:
//                           isLoading
//                               ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                               : const Text('Simpan mood'),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
