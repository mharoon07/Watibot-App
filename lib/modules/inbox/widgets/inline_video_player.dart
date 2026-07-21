import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/core/services/media_cache_service.dart';
import 'package:watibot/core/theme/app_theme.dart';

class InlineVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const InlineVideoPlayer({
    super.key,
    required this.videoUrl,
  });

  @override
  State<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<InlineVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  
  late final MediaCacheService _mediaCache;
  bool _isLoaded = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _mediaCache = Get.find<MediaCacheService>();
    _isLoaded = _mediaCache.isLoaded(widget.videoUrl);
    if (_isLoaded) {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isInitializing = true;
    });
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: ApiService.getMediaHeaders(widget.videoUrl) ?? const {},
      );
      await _videoPlayerController.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.primaryColor,
          handleColor: AppTheme.primaryColor,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade300,
        ),
        errorBuilder: (context, errorMessage) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.white, size: 42),
                SizedBox(height: 8),
                Text('Error playing video', style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      );
      
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _isLoaded = true;
        });
        _mediaCache.markAsLoaded(widget.videoUrl);
      }
    } catch (e) {
      debugPrint("Error initializing video: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_isLoaded && !_hasError) {
      _videoPlayerController.dispose();
      _chewieController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 150,
        width: 220,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text('Video unavailable', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    if (!_isLoaded) {
      return GestureDetector(
        onTap: _initializePlayer,
        child: Container(
          height: 150,
          width: 220,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Center(
                child: Icon(Icons.videocam, size: 48, color: Colors.white24),
              ),
              if (_isInitializing)
                const CircularProgressIndicator(color: Colors.white)
              else
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
      );
    }

    if (_chewieController != null && _videoPlayerController.value.isInitialized) {
      return Container(
        constraints: const BoxConstraints(maxHeight: 300),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: Chewie(
              controller: _chewieController!,
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 150,
        width: 220,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
  }
}
