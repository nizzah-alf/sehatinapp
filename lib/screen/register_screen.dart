import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sehatinapp/bloc/register/register_bloc.dart';
import 'package:sehatinapp/bloc/register/register_event.dart';
import 'package:sehatinapp/bloc/register/register_state.dart';
import 'package:sehatinapp/data/datasource/auth_local_datasource.dart';
import 'package:sehatinapp/data/datasource/auth_remote_datasource.dart';
import 'package:sehatinapp/data/model/request/register_request.dart';
import 'package:sehatinapp/data/model/request/auth_request.dart';
import 'package:sehatinapp/screen/page/homePage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  String name = '';
  String email = '';
  String password = '';

  final _authRemote = AuthRemoteDatasource();

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.5)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut();

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        final loginResponse = await _authRemote.login(
          AuthRequestModel(
            email: user.email ?? '',
            password: 'google-${user.uid}',
          ),
        );

        loginResponse.fold(
          (loginError) async {
            final registerResponse = await _authRemote.register(
              RegisterRequestModel(
                name: user.displayName ?? '',
                email: user.email ?? '',
                password: 'google-${user.uid}',
              ),
            );

            registerResponse.fold(
              (registerError) =>
                  _showErrorSnacBar('Gagal Register $registerError'),
              (registerData) async {
                await AuthLocalDatasource().saveAuthData(registerData);
                _showSuccessSnacBar(
                  'Yeyy kamu berhasil register dengan akun Google!',
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            );
          },
          (loginData) async {
            await AuthLocalDatasource().saveAuthData(loginData);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        );
      }
    } catch (e) {
      _showErrorSnacBar('Gagal login dengan Google: $e');
    }
  }

  void _showSuccessSnacBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnacBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<RegisterBloc, RegisterState>(
          listener: (context, state) async {
            if (state is RegisterSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registrasi berhasil!')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            } else if (state is RegisterFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            'Ayo Daftar!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Satu langkah kecil buat hidup yang lebih sehat.',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Nama', style: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      decoration: inputDecoration('Masukkan nama'),
                      onChanged: (val) => name = val,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Nama wajib diisi'
                                  : null,
                    ),
                    const SizedBox(height: 14),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Email', style: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      decoration: inputDecoration('Masukkan email'),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) => email = val,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!val.contains('@')) {
                          return 'Masukkan email yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Kata Sandi', style: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      obscureText: _obscurePassword,
                      decoration: inputDecoration(
                        'Masukkan kata sandi',
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      onChanged: (val) => password = val,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Kata sandi wajib diisi';
                        }
                        if (val.length < 6) {
                          return 'Minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<RegisterBloc>().add(
                              RegisterButtonPressed(
                                name: name,
                                username: '',
                                phone: '',
                                email: email,
                                password: password,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Atau melalui',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: signInWithGoogle,
                        icon: Image.asset('assets/google.png', height: 24),
                        label: const Text(
                          'Daftar dengan Google',
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun? ',
                          style: TextStyle(fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            'Masuk',
                            style: TextStyle(fontSize: 13, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

