import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatinapp/screen/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _pageIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/images/onboarding1.png',
      'title': 'Selamat datang di Sehatin!',
      'desc': 'Jaga tubuh dan pikiran tetap sehat dengan cara yang menyenangkan',
    },
    {
      'image': 'assets/images/onboarding2.png',
      'title': 'Artikel & Tips sehat',
      'desc': 'Baca artikel ringan dan inspiratif untuk hidup lebih seimbang',
    },
    {
      'image': 'assets/images/onboarding3.png',
      'title': 'Pantau gaya hidupmu',
      'desc': 'Lakukan aktivitas dan isi mood harianmu dengan mudah',
    },
  ];

  void _nextPage() {
    if (_pageIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_pageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _pageIndex = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  final data = onboardingData[index];
                  return _OnboardingPage(
                    imagePath: data['image']!,
                    title: data['title']!,
                    description: data['desc']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _pageIndex == 0
                ? const SizedBox(width: 56)
                : _buildCircleButton(Icons.arrow_back, _previousPage),
            Row(
              children: List.generate(
                onboardingData.length,
                (index) => _buildDot(index),
              ),
            ),
            _pageIndex == onboardingData.length - 1
                ? ElevatedButton(
                    onPressed: _goToRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    ),
                    child: Text(
                      'Mulai',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : _buildCircleButton(Icons.arrow_forward, _nextPage),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF007BFF), width: 2),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF007BFF)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: _pageIndex == index ? const Color(0xFF007BFF) : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF007BFF),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Image.asset(imagePath, height: 150, width: 150),
          const SizedBox(height: 32),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
