import 'dart:async';

import 'package:flutter/material.dart';

class VideoDurationTile extends StatefulWidget {
  const VideoDurationTile({
    super.key,
  });

  @override
  State<VideoDurationTile> createState() => _VideoDurationTileState();
}

class _VideoDurationTileState extends State<VideoDurationTile> {
  final ValueNotifier<Duration> _durationNotifier =
      ValueNotifier(Duration.zero);
  Timer? _timer;
  static const _timerDuration = Duration(seconds: 1);
  @override
  void initState() {
    _timer = Timer.periodic(_timerDuration, (value) {
      _durationNotifier.value =
          Duration(minutes: value.tick ~/ 60, seconds: value.tick % 60);
    });
    super.initState();
  }

  @override
  void dispose() {
    _durationNotifier.dispose();
    _timer?.cancel();
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
              valueListenable: _durationNotifier,
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
