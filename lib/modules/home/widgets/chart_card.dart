import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/home/models/dashboard_stats_model.dart';
import 'dart:ui' as ui;

class ChartCard extends StatelessWidget {
  final DashboardStatsModel data;

  const ChartCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Messages Sent this Month',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: data.totalMessages.toDouble()),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Text(
                            value.toInt().toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},'),
                            style: GoogleFonts.outfit(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              letterSpacing: -1,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_upward,
                              color: AppTheme.primaryColor,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${data.messageGrowth}%',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Report',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 64,
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOutCubic,
              builder: (context, progress, child) {
                return CustomPaint(
                  painter: _SmoothChartPainter(
                    data: data.messageChartData,
                    progress: progress,
                    color: AppTheme.primaryColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SmoothChartPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final Color color;

  _SmoothChartPainter({
    required this.data,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final height = size.height;

    final xStep = width / (data.length - 1);
    
    // Calculate points
    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = i * xStep;
      // Invert Y because 0 is top
      final y = height - (data[i] * height);
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        
        final controlPoint1 = Offset(p0.dx + xStep / 2, p0.dy);
        final controlPoint2 = Offset(p1.dx - xStep / 2, p1.dy);

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p1.dx,
          p1.dy,
        );
      }
    }

    // Path extraction for animation
    ui.PathMetrics pathMetrics = path.computeMetrics();
    Path extractPath = Path();
    for (ui.PathMetric metric in pathMetrics) {
      extractPath.addPath(
        metric.extractPath(0.0, metric.length * progress),
        Offset.zero,
      );
    }

    // Draw Gradient Fill
    if (progress > 0) {
      final fillPath = Path.from(extractPath);
      // Create a closed path to bottom
      if (points.isNotEmpty) {
        final lastPointX = width * progress;
        fillPath.lineTo(lastPointX, height);
        fillPath.lineTo(0, height);
        fillPath.close();

        final fillPaint = Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, 0),
            Offset(0, height),
            [
              color.withOpacity(0.3 * progress),
              color.withOpacity(0.0),
            ],
          )
          ..style = PaintingStyle.fill;
        canvas.drawPath(fillPath, fillPaint);
      }
    }

    // Draw the actual line
    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant _SmoothChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}
