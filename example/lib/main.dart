import 'package:flutter/material.dart';
import 'package:flutter_cam/flutter_cam.dart';

late final flutterCamDescription;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  flutterCamDescription = await FlutterCamInitialize().availableCam();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: FlutterCam(
          cameraDescriptions: flutterCamDescription,
          // callback triggered when upload button tapped
          onUploadTap: (files) {},
          //callback triggered when back button tapped
          onBackTap: () {},
        ),
      ),
    );
  }
}
