import 'package:flutter/material.dart';

enum CamMode { image, video }

class CamButton extends StatefulWidget {
  const CamButton({
    Key? key,
    this.onTap,
    this.onLongPress,
    this.onLongPressEnd,
  }) : super(key: key);
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(LongPressEndDetails details)? onLongPressEnd;

  @override
  State<CamButton> createState() => _CamButtonState();
}

class _CamButtonState extends State<CamButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  static const _animDuration = Duration(milliseconds: 250);
  CamMode _mode = CamMode.image;

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
      onLongPress: () {
        _animationController.forward();
        setState(() {
          _mode = CamMode.video;
        });
        widget.onLongPress?.call();
      },
      onLongPressEnd: (details) {
        _animationController.reverse();
        setState(() {
          _mode = CamMode.image;
        });
        widget.onLongPressEnd?.call(details);
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
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _mode == CamMode.image ? Colors.white : Colors.red),
          ),
        ),
      ),
    );
  }
}
