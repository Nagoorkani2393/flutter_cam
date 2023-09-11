import 'package:camera/camera.dart';

class CamController {
  CamController._();
  static final CamController i = CamController._();

  CameraController? _cameraController;
  CameraDescription? _cameraDescription;
  CameraController get controller => _cameraController!;

  void initCam(CameraDescription description) {
    if (_cameraController != null &&
        _cameraDescription != null &&
        _cameraDescription == description) {
      return;
    }
    _cameraDescription = description;
    _cameraController =
        CameraController(description, ResolutionPreset.ultraHigh);
  }

  Future<void> dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }
}
