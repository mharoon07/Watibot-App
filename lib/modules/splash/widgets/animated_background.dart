import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final bool isReady;
  const AnimatedBackground({super.key, required this.isReady});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
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
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _NetworkPainter(_controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _NetworkPainter extends CustomPainter {
  final double animationValue;
  _NetworkPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF25D366).withOpacity(0.03) // extremely subtle green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = const Color(0xFF25D366).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw subtle grid/network lines
    double spacing = 60.0;
    
    // Shift slightly based on animation
    double shiftX = (animationValue * 20) - 10;
    double shiftY = (animationValue * 10) - 5;

    for (double i = -spacing; i < size.width + spacing; i += spacing) {
      canvas.drawLine(
        Offset(i + shiftX, 0),
        Offset(i - shiftX, size.height),
        paint,
      );
    }

    for (double i = -spacing; i < size.height + spacing; i += spacing) {
      canvas.drawLine(
        Offset(0, i + shiftY),
        Offset(size.width, i - shiftY),
        paint,
      );
    }

    // Draw intersections as subtle nodes
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        // Only draw some nodes to keep it minimal
        if ((x + y) % (spacing * 3) == 0) {
          // add a breathing scale effect to the dots
          double radius = 2.0 + (animationValue * 1.5);
          canvas.drawCircle(Offset(x + shiftX, y + shiftY), radius, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
