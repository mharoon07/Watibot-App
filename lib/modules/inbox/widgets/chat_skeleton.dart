import 'package:flutter/material.dart';

class ChatSkeleton extends StatefulWidget {
  const ChatSkeleton({super.key});

  @override
  State<ChatSkeleton> createState() => _ChatSkeletonState();
}

class _ChatSkeletonState extends State<ChatSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubbleAlignments = [
      Alignment.centerLeft,
      Alignment.centerRight,
      Alignment.centerLeft,
      Alignment.centerRight,
      Alignment.centerLeft,
      Alignment.centerLeft,
      Alignment.centerRight,
    ];

    final bubbleWidths = [180.0, 240.0, 140.0, 200.0, 260.0, 160.0, 220.0];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final color = Colors.grey.shade300.withValues(alpha: _animation.value);
        return ListView.builder(
          itemCount: bubbleAlignments.length,
          padding: const EdgeInsets.symmetric(vertical: 16),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final isRight = bubbleAlignments[index] == Alignment.centerRight;
            return Align(
              alignment: bubbleAlignments[index],
              child: Container(
                width: bubbleWidths[index],
                height: 48,
                margin: EdgeInsets.only(
                  bottom: 12,
                  left: isRight ? 64 : 16,
                  right: isRight ? 16 : 64,
                ),
                decoration: BoxDecoration(
                  color: isRight ? const Color(0xFFDCF8C6).withValues(alpha: _animation.value) : color,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: Radius.circular(isRight ? 12 : 4),
                    bottomRight: Radius.circular(isRight ? 4 : 12),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
