import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:sehatinapp/bloc/logout/logout_bloc.dart';
import 'package:sehatinapp/bloc/logout/logout_event.dart';
import 'package:sehatinapp/bloc/logout/logout_state.dart';
import 'package:sehatinapp/cubit/user_cubit.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';
import 'package:sehatinapp/data/model/activity_model.dart';
import 'package:sehatinapp/screen/login_screen.dart';
import 'package:sehatinapp/screen/page/editProfilePage.dart';
import 'package:sehatinapp/screen/page/tentang_kami.dart';
import 'package:sehatinapp/screen/page/activity_data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().loadUserData();
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    final repo = AuthRepository();

    try {
      await repo.updateProfileImage(imageFile);
      if (!mounted) return;
      await context.read<UserCubit>().loadUserData();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update foto: $e')));
    }
  }

  void _editProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 120,
                    child: Image.asset(
                      'assets/logout.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Yakin ingin keluar?',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Jangan khawatir, data kamu aman.\nKamu bisa kembali kapan saja.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Colors.black),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Kembali',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            BlocProvider.of<LogoutBloc>(
                              context,
                            ).add(LogoutRequested());
                          },
                          child: const Text(
                            'Keluar',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildMenuItem({
    required Widget iconWidget,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          leading: iconWidget,
          title: Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black),
          ),
          dense: true,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget _buildIconProgress(double progress) {
    return LinearProgressIndicator(
      value: progress,
      minHeight: 8,
      backgroundColor: Colors.grey[300],
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activityData = Provider.of<ActivityData>(context);
    final progress = activityData.progress;
    final activities = activityData.activities;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Akun Profil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocListener<LogoutBloc, LogoutState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Berhasil keluar dari akun')),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          } else if (state is LogoutFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<UserCubit, Map<String, String?>>(
          builder: (context, userData) {
            final name = userData['name'] ?? '-';
            final email = userData['email'] ?? '-';
            final photoUrl = userData['photoUrl'];

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder:
                            (_) => Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Pilih dari galeri'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      pickAndUploadImage(ImageSource.gallery);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Ambil dari kamera'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      pickAndUploadImage(ImageSource.camera);
                                    },
                                  ),
                                ],
                              ),
                            ),
                      );
                    },
                    child: Stack(
                      children: [
                        photoUrl != null && photoUrl.isNotEmpty
                            ? CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                                '$photoUrl?${DateTime.now().millisecondsSinceEpoch}',
                              ),
                              onBackgroundImageError:
                                  (_, __) =>
                                      debugPrint('Gagal load foto profil.'),
                            )
                            : CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[300],
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(email, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(height: 30),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          photoUrl != null && photoUrl.isNotEmpty
                              ? CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(photoUrl),
                                backgroundColor: Colors.grey[300],
                              )
                              : CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey[300],
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Aktivitas hari ini'),
                                const SizedBox(height: 15),
                                activityData.isLoading
                                    ? const SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                    : _buildIconProgress(progress),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${(progress * 100).toInt()}%'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildMenuItem(
                    iconWidget: const Icon(
                      Icons.edit,
                      color: Colors.black87,
                      size: 20,
                    ),
                    title: 'Edit Profile',
                    onTap: () => _editProfile(context),
                  ),

                  const SizedBox(height: 8),

                  _buildMenuItem(
                    iconWidget: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black87),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'i',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: 'Tentang Kami',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TentangKamiPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () => _logout(context),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: const ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        leading: Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 20,
                        ),
                        title: Text(
                          'Keluar Akun',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
