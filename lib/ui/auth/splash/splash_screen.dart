import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Navigate to next screen after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      // Add navigation to your next screen here
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    });
    
    // Create animation controller for fade in effect
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    
    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffFF6B35), // Vibrant orange background
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xffFF6B35), // Vibrant orange
                Color(0xffFF8C42), // Medium orange
                Color(0xffFFA36C), // Light orange
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated background circles for visual effect
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              
              // Center animated food logo with fade in effect
              Center(
                child: FadeTransition(
                  opacity: _animation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Main animation
                      Lottie.asset(
                        'assets/animations/animation.json',
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                      
                      // App title with elegant styling
                      const SizedBox(height: 30),
                      const Text(
                        'کال ویچ',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          //fontFamily: 'Arial',
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 5),
                              blurRadius: 10,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    
                      // Subtitle
                      const SizedBox(height: 10),
                      const Text(
                        'مدیریت ساندویچ و انبار',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom decorative element
              // const Positioned(
              //   bottom: 30,
              //   left: 0,
              //   right: 0,
              //   child: Center(
              //     child: Text(
              //       '© ۱۴۰۲ کال ویچ. تمامی حقوق محفوظ است.',
              //       style: TextStyle(
              //         color: Colors.white54,
              //         fontSize: 12,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}