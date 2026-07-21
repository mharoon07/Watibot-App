import 'package:flutter/material.dart';

class AnimatedLogo extends StatelessWidget {
  final bool isReady;
  const AnimatedLogo({super.key, required this.isReady});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isReady ? 1.0 : 0.90,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isReady ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        child: Container(
          width: 280, // Wide container for the text logo
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (isReady)
                BoxShadow(
                  color: const Color(0xFF25D366).withOpacity(0.10),
                  blurRadius: 50,
                  spreadRadius: 5,
                ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/logo.png', // Save your attached image as assets/logo.png
              width: 250,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // If asset is missing, show a stylish placeholder text
                return const Text(
                  'WatiBot',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF25D366),
                    letterSpacing: -2,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
