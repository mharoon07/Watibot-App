import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/core/services/media_cache_service.dart';

class LazyImageWidget extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const LazyImageWidget({
    super.key,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<LazyImageWidget> createState() => _LazyImageWidgetState();
}

class _LazyImageWidgetState extends State<LazyImageWidget> {
  late final MediaCacheService _mediaCache;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _mediaCache = Get.find<MediaCacheService>();
    _isLoaded = _mediaCache.isLoaded(widget.imageUrl);
  }

  void _loadMedia() {
    setState(() {
      _isLoaded = true;
    });
    _mediaCache.markAsLoaded(widget.imageUrl);
  }

  String _getBlurredThumbnailUrl(String url) {
    if (url.contains('res.cloudinary.com') && url.contains('/upload/')) {
      return url.replaceFirst('/upload/', '/upload/w_50,e_blur:200,f_auto,q_auto/');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 250),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              headers: ApiService.getMediaHeaders(widget.imageUrl),
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 150,
                width: 200,
                child: Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
              ),
            ),
          ),
        ),
      );
    }

    final isCloudinary = widget.imageUrl.contains('res.cloudinary.com');

    return GestureDetector(
      onTap: _loadMedia,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 250, minHeight: 150, minWidth: 200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.passthrough,
            children: [
              if (isCloudinary)
                Image.network(
                  _getBlurredThumbnailUrl(widget.imageUrl),
                  fit: BoxFit.cover,
                  headers: ApiService.getMediaHeaders(widget.imageUrl),
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.black12),
                )
              else
                Container(color: Colors.black12),
              
              // Dark overlay for better contrast
              Container(color: Colors.black.withOpacity(0.3)),
              
              // Download Button
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
