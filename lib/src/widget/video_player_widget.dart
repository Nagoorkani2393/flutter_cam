import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget(
      {super.key, required this.file, required this.thumbnail});

  final File file;
  final File thumbnail;
  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final VideoPlayerController controller;
  final ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(false);
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);
  bool _isInitialized = false;
  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(widget.file);
    controller.initialize().then((_) => setState(() {
          _isInitialized = true;
        }));
    controller.play();
    controller.addListener(() {
      if (controller.value.isPlaying) {
        _isPlaying.value = true;
      } else {
        _isPlaying.value = false;
      }

      _progressNotifier.value = (controller.value.position.inSeconds /
              controller.value.duration.inSeconds)
          .toDouble()
          .clamp(0.0, 1.0);
    });
  }

  @override
  dispose() {
    controller.dispose();
    _isPlaying.dispose();
    _progressNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(onTap: _onPlayPause, child: VideoPlayer(controller)),
        if (!_isInitialized)
          Image.file(
            widget.thumbnail,
            fit: BoxFit.contain,
          ),
        Center(
          child: ValueListenableBuilder<bool>(
              valueListenable: _isPlaying,
              builder: (context, value, child) {
                return GestureDetector(
                  onTap: _onPlayPause,
                  child: !value
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.6),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              }),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          right: 0,
          child: Material(
            type: MaterialType.transparency,
            child: ValueListenableBuilder<double>(
              valueListenable: _progressNotifier,
              builder: (context, position, child) {
                debugPrint("progress value == $position");
                return LinearProgressIndicator(
                  value: position,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white.withOpacity(0.2),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onPlayPause() {
    if (_isPlaying.value) {
      controller.pause();
    } else {
      controller.play();
    }
  }
}
