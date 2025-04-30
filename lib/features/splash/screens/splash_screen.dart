import 'package:flutter/material.dart';
import 'dart:async';

import 'package:workout_tracker/features/dashboard/screens/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Start the fade-in animation
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    // Delay for splash screen display (3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    // Check if widget is still mounted before navigating
    if (mounted) {
      // Navigate to your home screen
      // Replace this with your actual home screen route
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color darkerColor =
        Color.lerp(primaryColor, Colors.black, 0.3) ?? primaryColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6B7FD7), // Soft purple
              const Color(0xFF8B9FE8), // Light purple-blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/app_logo.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                          size: 120,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(height: 40),

                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: [
                      Text(
                        'Workout Tracker Pro',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Track your fitness journey',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
