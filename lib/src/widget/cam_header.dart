import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../repo/cam_controller.dart';

class CamHeader extends StatelessWidget {
  const CamHeader({
    Key? key,
    this.onBackTap,
    required this.onCamSwitch,
  }) : super(key: key);

  final VoidCallback onCamSwitch;
  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BackButton(onBackTap: onBackTap),
          Row(
            children: [
              const _FlashButton(),
              const SizedBox(width: 20),
              _SwitchCamButton(
                onCamSwitch: onCamSwitch,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlashButton extends StatefulWidget {
  const _FlashButton({Key? key}) : super(key: key);

  @override
  State<_FlashButton> createState() => _FlashButtonState();
}

class _FlashButtonState extends State<_FlashButton> {
  FlashMode flashMode = FlashMode.off;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashFactory: InkRipple.splashFactory,
        onTap: () {
          debugPrint(flashMode.toString());
          if (flashMode == FlashMode.off) {
            setState(() {
              flashMode = FlashMode.always;
              CamController.i.controller.setFlashMode(FlashMode.always);
            });
          } else {
            setState(() {
              flashMode = FlashMode.off;
              CamController.i.controller.setFlashMode(FlashMode.off);
            });
          }
        },
        child: Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Colors.black.withOpacity(0.5)),
            child: flashMode == FlashMode.off
                ? const Icon(
                    Icons.flash_off,
                    color: Colors.white,
                  )
                : const Icon(
                    Icons.flash_on,
                    color: Colors.white,
                  )),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onBackTap});

  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashFactory: InkRipple.splashFactory,
        highlightColor: Colors.white,
        onTap: onBackTap,
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _SwitchCamButton extends StatefulWidget {
  const _SwitchCamButton({required this.onCamSwitch});

  final VoidCallback onCamSwitch;

  @override
  State<_SwitchCamButton> createState() => _SwitchCamButtonState();
}

class _SwitchCamButtonState extends State<_SwitchCamButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _flipAnimation;
  static const _flipDuration = Duration(milliseconds: 250);

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: _flipDuration,
      reverseDuration: _flipDuration,
    );
    _flipAnimation =
        Tween<double>(begin: pi, end: 0).animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }

    widget.onCamSwitch.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(_flipAnimation.value),
            child: child!,
          );
        },
        child: Container(
          width: 32.0,
          height: 32.0,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.black.withOpacity(0.5)),
          child: const Icon(
            Icons.cameraswitch_outlined,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
