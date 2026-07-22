import 'package:flutter/material.dart';
import 'package:watibot/core/services/api_service.dart';

class LazyImageWidget extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const LazyImageWidget({
    super.key,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 250, minHeight: 120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            headers: ApiService.getMediaHeaders(imageUrl),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 180,
                color: const Color(0xFFE2E8F0),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                    color: const Color(0xFF00B074),
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              height: 150,
              width: 200,
              color: const Color(0xFFF1F5F9),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broken_image, size: 36, color: Color(0xFF94A3B8)),
                    SizedBox(height: 6),
                    Text('Failed to load image', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
