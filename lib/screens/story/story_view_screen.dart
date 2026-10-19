import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryMediaItem {
  final String url;
  final String type;

  StoryMediaItem({
    required this.url,
    required this.type,
  });

  factory StoryMediaItem.fromMap(Map<String, dynamic> map) {
    return StoryMediaItem(
      url: map['url'] as String,
      type: map['type'] as String,
    );
  }

  @override
  String toString() => 'StoryMediaItem(url: $url, type: $type)';
}

class StoryViewScreen extends StatefulWidget {
  final List<StoryMediaItem> media;

  const StoryViewScreen({
    super.key,
    required this.media,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isDisposed = false;
  VideoPlayerController? _videoController;
  AnimationController? _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCurrentStory();
  }

  Future<void> _initializeCurrentStory() async {
    if (_isDisposed) return;

    _progressAnimation?.stop();
    _progressAnimation?.dispose();
    _videoController?.removeListener(_videoCompletionListener);
    await _videoController?.dispose();
    _videoController = null;

    setState(() => _isLoading = true);

    final currentItem = widget.media[_currentIndex];
    final url = currentItem.url;
    final type = currentItem.type;

    if (type == 'video') {
      try {
        _videoController = url.startsWith('http')
            ? VideoPlayerController.network(url)
            : VideoPlayerController.file(File(url));

        await _videoController!.initialize();

        if (_isDisposed) return;

        _videoController!
          ..play()
          ..addListener(_videoCompletionListener);

        _startProgressAnimation(_videoController!.value.duration);
        setState(() => _isLoading = false);
      } catch (_) {
        _advanceToNextStory();
      }
    } else {
      // Photo handling
      final file = File(url);
      if (!url.startsWith('http') && !file.existsSync()) {
        _advanceToNextStory();
        return;
      }

      _startProgressAnimation(const Duration(seconds: 4));
      setState(() => _isLoading = false);
    }
  }

  void _startProgressAnimation(Duration duration) {
    _progressAnimation = AnimationController(vsync: this, duration: duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _advanceToNextStory();
        }
      });
    _progressAnimation!.forward();
  }

  void _videoCompletionListener() {
    if (_videoController != null &&
        _videoController!.value.isInitialized &&
        _videoController!.value.position >= _videoController!.value.duration &&
        !_isDisposed) {
      _advanceToNextStory();
    }
  }

  void _advanceToNextStory() {
    if (_isDisposed) return;

    if (_currentIndex < widget.media.length - 1) {
      setState(() => _currentIndex++);
      _initializeCurrentStory();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _videoController?.removeListener(_videoCompletionListener);
    _videoController?.dispose();
    _progressAnimation?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Text('No stories available',
                style: TextStyle(color: Colors.white))),
      );
    }

    final currentItem = widget.media[_currentIndex];
    final url = currentItem.url;
    final type = currentItem.type;

    final imageProvider = url.startsWith('http')
        ? NetworkImage(url)
        : FileImage(File(url)) as ImageProvider;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _advanceToNextStory,
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : (type == 'video' && _videoController != null)
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : Image(
                          image: imageProvider,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Row(
              children: List.generate(widget.media.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: LinearProgressIndicator(
                      value: index < _currentIndex
                          ? 1.0
                          : index == _currentIndex
                              ? _progressAnimation?.value ?? 0.0
                              : 0.0,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
