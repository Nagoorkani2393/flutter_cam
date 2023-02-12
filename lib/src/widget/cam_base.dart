import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../repo/cam_controller.dart';

class CameraBase extends StatefulWidget {
  const CameraBase({
    super.key,
    required this.cameraController,
  });
  final CameraController cameraController;

  @override
  State<CameraBase> createState() => _CameraBaseState();
}

class _CameraBaseState extends State<CameraBase> {
  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void _initialize() {
    widget.cameraController.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(CameraBase oldWidget) {
    widget.cameraController.cameraId != oldWidget.cameraController.cameraId
        ? _initialize()
        : null;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    CamController.i.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraPreview(widget.cameraController);
  }
}
