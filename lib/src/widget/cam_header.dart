import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../enum/cam_mode.dart';
import '../repo/cam_controller.dart';

class CamHeader extends StatelessWidget {
  const CamHeader({
    Key? key,
    this.title,
    this.onBackTap,
    required this.onCamSwitch,
    required this.camModeNotifier,
  }) : super(key: key);

  final VoidCallback onCamSwitch;
  final VoidCallback? onBackTap;
  final String? title;
  final ValueNotifier<CamMode> camModeNotifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BackButton(onBackTap: onBackTap),
          if (title != null)
            Expanded(
              child: Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700),
              ),
            ),
          Row(
            children: [
              _CamModeButton(camModeNotifier: camModeNotifier),
              const SizedBox(width: 15),
              const _FlashButton(),
              const SizedBox(width: 15),
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
  void initState() {
    CamController.i.controller.setFlashMode(FlashMode.off);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashFactory: InkRipple.splashFactory,
        onTap: () {
          if (flashMode == FlashMode.off) {
            setState(() {
              flashMode = FlashMode.always;
              CamController.i.controller.setFlashMode(FlashMode.always);
            });
          } else if (flashMode == FlashMode.always) {
            setState(() {
              flashMode = FlashMode.auto;
              CamController.i.controller.setFlashMode(FlashMode.auto);
            });
          } else if (flashMode == FlashMode.auto) {
            setState(() {
              flashMode = FlashMode.off;
              CamController.i.controller.setFlashMode(FlashMode.off);
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32.0,
          height: 32.0,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.black.withOpacity(0.5)),
          child: flashMode == FlashMode.off
              ? const Icon(
                  Icons.flash_off,
                  color: Colors.white,
                )
              : flashMode == FlashMode.always
                  ? const Icon(
                      Icons.flash_on,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.flash_auto,
                      color: Colors.white,
                    ),
        ),
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

class _CamModeButton extends StatefulWidget {
  const _CamModeButton({required this.camModeNotifier});

  final ValueNotifier<CamMode> camModeNotifier;

  @override
  State<_CamModeButton> createState() => _CamModeButtonState();
}

class _CamModeButtonState extends State<_CamModeButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.camModeNotifier.value == CamMode.image) {
          widget.camModeNotifier.value = CamMode.video;
        } else {
          widget.camModeNotifier.value = CamMode.image;
        }
      },
      child: Container(
        height: 32.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black.withOpacity(0.5)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValueListenableBuilder<CamMode>(
                valueListenable: widget.camModeNotifier,
                builder: (context, value, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: value == CamMode.image
                        ? Text(
                            value.name.toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          )
                        : Text(
                            value.name.toUpperCase(),
                            style: const TextStyle(color: Colors.red),
                          ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
