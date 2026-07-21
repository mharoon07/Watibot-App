import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/core/theme/app_theme.dart';

class StatsCard extends StatefulWidget {
  final String title;
  final String value;
  final double trend;
  final String iconCode;
  final int index;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.iconCode,
    required this.index,
  });

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIconData(String code) {
    switch (code) {
      case 'people':
        return Icons.people_outline;
      case 'account_tree':
        return Icons.account_tree_outlined;
      case 'rocket_launch':
        return Icons.rocket_launch_outlined;
      case 'smart_toy':
        return Icons.smart_toy_outlined;
      case 'support_agent':
        return Icons.support_agent_outlined;
      case 'check_circle':
        return Icons.check_circle_outline;
      default:
        return Icons.bar_chart;
    }
  }

  Color _getIconColor(String code) {
    switch (code) {
      case 'people':
        return Colors.blue;
      case 'account_tree':
        return Colors.purple;
      case 'rocket_launch':
        return Colors.orange;
      case 'smart_toy':
        return Colors.redAccent;
      case 'support_agent':
        return Colors.teal;
      case 'check_circle':
        return AppTheme.primaryColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.trend >= 0;
    final trendColor = isPositive ? AppTheme.successColor : AppTheme.errorColor;
    final iconColor = _getIconColor(widget.iconCode);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isHovered 
                      ? Colors.black.withOpacity(0.06) 
                      : Colors.black.withOpacity(0.02),
                  blurRadius: _isHovered ? 12 : 8,
                  offset: Offset(0, _isHovered ? 6 : 2),
                ),
              ],
              border: Border.all(
                color: _isHovered ? AppTheme.borderColor : Colors.transparent,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconData(widget.iconCode),
                        color: iconColor,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.value,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  widget.title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
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
