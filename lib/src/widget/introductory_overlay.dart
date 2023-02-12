import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class IntroductoryOverlay {
  static void showIntroductoryOverlay(BuildContext context) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(builder: (BuildContext context) {
      final width = MediaQuery.of(context).size.width;
      final height = MediaQuery.of(context).size.height;
      final center = Offset(width / 2, height / 2);
      return GestureDetector(
        onTap: () {
          overlayEntry?.remove();
          overlayEntry = null;
        },
        child: Material(
          color: Colors.black.withOpacity(0.5),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Slide to open / close preview",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Icon(
                        Icons.touch_app_outlined,
                        color: Colors.white,
                        size: 48,
                      ).animate(
                          onPlay: (controller) => controller.repeat(),
                          effects: [
                            const Effect(
                              curve: Curves.easeInOut,
                              duration: Duration(milliseconds: 2000),
                            ),
                          ]).moveX(
                        begin: 0,
                        end: (-center.dx / 2),
                      )
                    ],
                  ),
                ),
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: Column(
                      children: [
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..translate(center.dx / 4)
                            ..rotateZ(-pi / 3),
                          child: Icon(
                            Icons.touch_app_outlined,
                            color: Colors.white.withOpacity(0.7),
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Tap to image\nTap and hold to video",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )),
                Positioned(
                    left: 10,
                    bottom: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Tap to pick image\nfrom Gallery",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 40),
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateZ(pi / 3),
                          child: Icon(
                            Icons.touch_app_outlined,
                            color: Colors.white.withOpacity(0.7),
                            size: 42,
                          ),
                        )
                      ],
                    )),
                Positioned(
                    right: 10,
                    top: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          color: Colors.white.withOpacity(0.7),
                          size: 42,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Tap to flip camera",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )),
                Positioned(
                  right: 60,
                  top: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..translate(-center.dx / 4)
                          ..rotateZ(pi / 3),
                        child: Icon(
                          Icons.touch_app_outlined,
                          color: Colors.white.withOpacity(0.7),
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..translate(-center.dx / 4),
                        child: const Text(
                          "Tap to auto flash",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });

    if (overlayEntry != null) {
      Overlay.of(context).insert(overlayEntry!);
    }
  }
}
