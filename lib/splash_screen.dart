import 'dart:async';
import 'package:flutter/material.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/company_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Smart Payslip',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3C88),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Fast, Safe, Simple',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 180,
                  child: Image.asset(
                    'assets/images/loading.gif',
                    height: 70,
                    fit: BoxFit.contain,
                  ),
                ),

                // const SizedBox(
                //   width: 180,
                //   child: LinearProgressIndicator(),
                // ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Text(
              'Developed By The BAJ IT Team',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
