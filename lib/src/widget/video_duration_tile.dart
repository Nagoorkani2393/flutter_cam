import 'dart:async';

import 'package:flutter/material.dart';

import '../enum/video_mode.dart';

class VideoDurationTile extends StatefulWidget {
  const VideoDurationTile({
    super.key,
    required this.videoPlayPause,
    required this.durationNotifier,
  });

  final StreamController<VideoMode> videoPlayPause;
  final ValueNotifier<Duration> durationNotifier;

  @override
  State<VideoDurationTile> createState() => _VideoDurationTileState();
}

class _VideoDurationTileState extends State<VideoDurationTile> {
  final Duration _timerDuration = const Duration(seconds: 1);
  late Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(_timerDuration, (timer) {
      widget.durationNotifier.value =
          (widget.durationNotifier.value + _timerDuration);
    });

    widget.videoPlayPause.stream.listen((event) {
      if (event == VideoMode.pause) {
        _timer?.cancel();
        _timer = null;
      } else {
        _timer = Timer.periodic(_timerDuration, (timer) {
          widget.durationNotifier.value =
              widget.durationNotifier.value + _timerDuration;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.black.withOpacity(0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Container(
              height: 12.0,
              width: 12.0,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Flexible(
            flex: 2,
            child: ValueListenableBuilder<Duration>(
              valueListenable: widget.durationNotifier,
              builder: (context, duration, child) => Text(
                "${duration.inMinutes} : ${duration.inSeconds.toString().padLeft(2, "0")}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
