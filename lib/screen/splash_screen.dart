import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sehatinapp/screen/onboarding/onboarding_screen.dart';
import 'package:sehatinapp/screen/page/homePage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _circleController;
  late final AnimationController _logoController;

  late final Animation<double> _circleAnimation;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  bool _showLogo = false;

  final _storage = FlutterSecureStorage(); 

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600), 
    );

    _circleAnimation = Tween<double>(begin: 0.0, end: 2.5).animate(
      CurvedAnimation(
        parent: _circleController,
        curve: Curves.easeOutQuart, 
      ),
    );
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900), 
    );

    // Animasi untuk logo
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(seconds: 1)); 
    await _circleController.forward(); 
    await Future.delayed(
      const Duration(milliseconds: 100),
    );

    setState(() {
      _showLogo = true;
    });

    _logoController.forward(); 
    await Future.delayed(const Duration(seconds: 3)); 

    if (mounted) {
      String? token = await _storage.read(
        key: 'token',
      ); 

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  token != null && token.isNotEmpty
                      ? const HomePage()
                      : const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _circleController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF3787F4)),
          AnimatedBuilder(
            animation: _circleAnimation,
            builder: (context, child) {
              return ClipPath(
                clipper: CircleClipper(_circleAnimation.value),
                child: Container(color: Colors.white),
              );
            },
          ),

          if (_showLogo)
            Center(
              child: FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: const Image(
                    image: AssetImage('assets/images/logo.png'),
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CircleClipper extends CustomClipper<Path> {
  final double scale;

  CircleClipper(this.scale);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * scale;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(CircleClipper oldClipper) => scale != oldClipper.scale;
}

