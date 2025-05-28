import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../config/themes/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )
      ..forward().then((_) {
        if (mounted) {
          setState(() {
            _animationCompleted = true;
          });
        }
      });

    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Wait for the animation to complete (2 seconds) + 1 second buffer
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isSignedIn = await userProvider.isUserSignedIn();

    if (!mounted) return;

    if (isSignedIn) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo with Scale Animation
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale:
                        Tween<double>(begin: 0.5, end: 1.0)
                            .animate(
                              CurvedAnimation(
                                parent: _controller,
                                curve: Curves.elasticOut,
                              ),
                            )
                            .value,
                    child: child,
                  );
                },
                child: Container(
                  width: 150,
                  height: 150,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.fitness_center_outlined,
                    color: AppTheme.exerciseRingColor,
                    size: 64,
                  ),
                ),
              ),

              // App Name with Fade In Animation
              AnimatedOpacity(
                opacity: _animationCompleted ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  'Workout Tracker Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedOpacity(
                opacity: _animationCompleted ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  'Transform Your Fitness Journey',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
