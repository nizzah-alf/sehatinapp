import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sehatinapp/cubit/user_cubit.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _storage = const FlutterSecureStorage();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool isButtonEnabled = false;
  bool showSuccessMessage = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _nameController.addListener(_validateFields);
    _emailController.addListener(_validateFields);
  }

  Future<void> _loadUserData() async {
    final name = await _storage.read(key: 'userName');
    final email = await _storage.read(key: 'userEmail');

    if (mounted) {
      setState(() {
        _nameController.text = name ?? '';
        _emailController.text = email ?? '';
        _validateFields();
      });
    }
  }

  void _validateFields() {
    final isValid =
        _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        RegExp(
          r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
        ).hasMatch(_emailController.text.trim());

    if (mounted) {
      setState(() {
        isButtonEnabled = isValid;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final repo = AuthRepository();
      final result = await repo.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      final user = result['user'];
      await _storage.write(key: 'userName', value: user['name']);
      await _storage.write(key: 'userEmail', value: user['email']);
      // username tidak di-save
      if (user['image'] != null) {
        await _storage.write(key: 'photoUrl', value: user['image']);
      }

      await context.read<UserCubit>().loadUserData();

      setState(() {
        showSuccessMessage = true;
      });

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() => showSuccessMessage = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal update profil: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Nama'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Email'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Masukkan email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 36),
            Center(
              child: SizedBox(
                width: screenWidth * 0.7,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      isButtonEnabled && !isLoading ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isButtonEnabled
                            ? const Color(0xFF3B82F6)
                            : Colors.grey[300],
                    foregroundColor:
                        isButtonEnabled ? Colors.white : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : const Text('Ganti'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (showSuccessMessage)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Profil berhasil diperbarui',
                        style: TextStyle(fontWeight: FontWeight.w500),
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
}
