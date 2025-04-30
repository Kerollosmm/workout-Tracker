import 'dart:ui';

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
  double _textOpacity = 0.0;
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Start progress animation
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_progressValue < 1.0 && mounted) {
        setState(() {
          _progressValue += 0.05;
        });
      } else {
        timer.cancel();
      }
    });

    // Fade-in animations
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    // Text appearance delay
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _textOpacity = 1.0;
        });
      }
    });

    // Navigate after 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => DashboardScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F3460),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container with Glassmorphism
                      AnimatedOpacity(
                        opacity: _opacity,
                        duration: const Duration(milliseconds: 800),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: ModalRoute.of(context)!.animation!,
                            curve: Curves.easeOutBack,
                          )),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 40),
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/app_logo.png',
                                width: 130,
                                height: 130,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.fitness_center_rounded,
                                    color: theme.primaryColorLight,
                                    size: 130,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: LinearProgressIndicator(
                          value: _progressValue,
                          color: theme.primaryColorLight.withOpacity(0.9),
                          backgroundColor: Colors.white.withOpacity(0.1),
                          minHeight: 3,
                        ),
                      ),

                      // Text Content
                      AnimatedOpacity(
                        opacity: _textOpacity,
                        duration: const Duration(milliseconds: 800),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            children: [
                              Text(
                                'Workout Tracker Pro',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  fontFamily: 'Poppins',
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Transform Your Fitness Journey',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.6,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Glow Effect
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}