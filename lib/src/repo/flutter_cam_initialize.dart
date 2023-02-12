import 'package:camera/camera.dart';

class FlutterCamInitialize {
  Future<List<CameraDescription>> availableCam() async {
    return await availableCameras();
  }
}
