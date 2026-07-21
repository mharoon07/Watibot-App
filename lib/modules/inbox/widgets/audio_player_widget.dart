import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'package:watibot/core/services/media_cache_service.dart';
import 'package:watibot/core/theme/app_theme.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final bool isOutgoing;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.isOutgoing,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;
  
  late final MediaCacheService _mediaCache;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _mediaCache = Get.find<MediaCacheService>();
    _isLoaded = _mediaCache.isLoaded(widget.audioUrl);
    
    if (_isLoaded) {
      _isLoading = true;
      _initAudio();
    }
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);
      
      _audioPlayer.durationStream.listen((duration) {
        if (mounted && duration != null) {
          setState(() {
            _duration = duration;
            _isLoading = false;
          });
        }
      });

      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            if (state.processingState == ProcessingState.completed) {
              _isPlaying = false;
              _audioPlayer.seek(Duration.zero);
              _audioPlayer.pause();
            }
          });
        }
      });
      
      _mediaCache.markAsLoaded(widget.audioUrl);
      
    } catch (e) {
      debugPrint('Error loading audio: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _loadMedia() {
    setState(() {
      _isLoaded = true;
      _isLoading = true;
    });
    _initAudio();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = widget.isOutgoing ? const Color(0xFF059669) : AppTheme.primaryColor;
    final Color trackColor = widget.isOutgoing ? Colors.white54 : const Color(0xFFE2E8F0);
    final Color progressColor = widget.isOutgoing ? const Color(0xFF059669) : AppTheme.primaryColor;

    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isLoaded)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              color: iconColor,
              iconSize: 36,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _loadMedia,
            )
          else if (_isLoading)
            const SizedBox(
              width: 40,
              height: 40,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: iconColor,
                size: 36,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                if (_isPlaying) {
                  _audioPlayer.pause();
                } else {
                  _audioPlayer.play();
                }
              },
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: progressColor,
                    inactiveTrackColor: trackColor,
                    thumbColor: progressColor,
                  ),
                  child: Slider(
                    value: _position.inMilliseconds.toDouble(),
                    min: 0.0,
                    max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                    onChanged: (value) {
                      if (_isLoaded) {
                        _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.isOutgoing ? const Color(0xFF475569) : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        _isLoaded ? _formatDuration(_duration) : "--:--",
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.isOutgoing ? const Color(0xFF475569) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
