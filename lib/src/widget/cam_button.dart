import 'package:flutter/material.dart';

import '../enum/cam_mode.dart';

class CamButton extends StatefulWidget {
  const CamButton({
    Key? key,
    this.onTap,
    required this.camModeNotifier,
    required this.isVideoRecording,
  }) : super(key: key);
  final VoidCallback? onTap;
  final ValueNotifier<CamMode> camModeNotifier;
  final ValueNotifier<bool> isVideoRecording;

  @override
  State<CamButton> createState() => _CamButtonState();
}

class _CamButtonState extends State<CamButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  static const _animDuration = Duration(milliseconds: 250);

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: _animDuration, reverseDuration: _animDuration);
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.2).animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _animationController.forward();
        Future.delayed(
          _animDuration,
          () => _animationController.reverse(),
        );
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            ScaleTransition(scale: _scaleAnimation, child: child!),
        child: Container(
          padding: const EdgeInsets.all(7.0),
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
          child: ValueListenableBuilder<CamMode>(
            valueListenable: widget.camModeNotifier,
            builder: (context, value, child) {
              if (value == CamMode.video) {
                return ValueListenableBuilder<bool>(
                  valueListenable: widget.isVideoRecording,
                  builder: (context, isRecording, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 300),
                      child: isRecording
                          ? Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  shape: BoxShape.rectangle,
                                  color: Colors.red),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.red),
                            ),
                    );
                  },
                );
              }

              return Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}
