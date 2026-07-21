import 'package:flutter/material.dart';

class CustomLoader extends StatefulWidget {
  final bool isReady;
  const CustomLoader({super.key, required this.isReady});

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isReady ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeIn,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              // Create a staggered wave effect
              final delay = index * 0.2;
              double animationValue = (_controller.value - delay) % 1.0;
              if (animationValue < 0) animationValue += 1.0;

              // Pulse math
              double scale = 1.0;
              double opacity = 0.3;

              if (animationValue < 0.5) {
                // scale up and fade in
                final progress = animationValue / 0.5;
                scale = 1.0 + (0.5 * Curves.easeInOut.transform(progress));
                opacity = 0.3 + (0.7 * Curves.easeInOut.transform(progress));
              } else {
                // scale down and fade out
                final progress = (animationValue - 0.5) / 0.5;
                scale = 1.5 - (0.5 * Curves.easeInOut.transform(progress));
                opacity = 1.0 - (0.7 * Curves.easeInOut.transform(progress));
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withOpacity(opacity),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
