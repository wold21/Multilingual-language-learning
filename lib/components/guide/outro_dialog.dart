import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OutroGuide extends StatelessWidget {
  const OutroGuide({super.key});

  @override
  Widget build(BuildContext context) {
    const String FIRST_RUN_KEY = 'is_first_run';
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool(FIRST_RUN_KEY, false);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Container(
              color: Colors.black.withOpacity(0.85),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/dog.png',
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Thank you for using Laboca!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Click anywhere to close',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
