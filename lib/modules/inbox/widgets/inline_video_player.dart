import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:watibot/core/services/api_service.dart';
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
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant InlineVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeControllers();
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    if (!mounted) return;
    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    try {
      final String sanitizedUrl = _sanitizeUrl(widget.videoUrl);
      final bool isLocal = !sanitizedUrl.startsWith('http://') && !sanitizedUrl.startsWith('https://');

      if (isLocal) {
        final file = File(sanitizedUrl);
        if (!await file.exists()) {
          throw Exception('Local video file not found');
        }
        _videoPlayerController = VideoPlayerController.file(file);
      } else {
        final headers = ApiService.getMediaHeaders(sanitizedUrl);
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(sanitizedUrl),
          httpHeaders: headers ?? const {},
        );
      }

      await _videoPlayerController!.initialize();

      final double ratio = _videoPlayerController!.value.aspectRatio > 0
          ? _videoPlayerController!.value.aspectRatio
          : 16 / 9;
      
      // Ensure the aspect ratio is at least 0.8 to prevent UI overflow on narrow portrait videos
      final double displayRatio = ratio < 0.8 ? 0.8 : ratio;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: displayRatio,
        allowPlaybackSpeedChanging: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.primaryColor,
          handleColor: AppTheme.primaryColor,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade300,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 36),
                const SizedBox(height: 6),
                Text(
                  'Error playing video',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint("Video initialization failed for ${widget.videoUrl}: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitializing = false;
        });
      }
    }
  }

  String _sanitizeUrl(String url) {
    if (url.startsWith('http://localhost:3000')) {
      return url.replaceFirst('http://localhost:3000', ApiService.baseUrl.replaceAll('/api/v1', ''));
    }
    return url;
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _chewieController = null;
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return GestureDetector(
        onTap: _initializePlayer,
        child: Container(
          height: 160,
          width: 240,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_outline, size: 44, color: Colors.white70),
                const SizedBox(height: 8),
                Text(
                  'Tap to play video',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Retry', style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isInitializing || _videoPlayerController == null || !_videoPlayerController!.value.isInitialized) {
      return Container(
        height: 160,
        width: 240,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2.5),
          ),
        ),
      );
    }

    final double ratio = _videoPlayerController!.value.aspectRatio > 0
        ? _videoPlayerController!.value.aspectRatio
        : 16 / 9;
    final double displayRatio = ratio < 0.8 ? 0.8 : ratio;

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: displayRatio,
          child: Chewie(
            controller: _chewieController!,
          ),
        ),
      ),
    );
  }
}
