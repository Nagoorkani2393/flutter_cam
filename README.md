<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->
# Flutter Camera
A Flutter Camera package for android and ios.
credits:

camera, video_player, video_thumbnail, file_picker
flutter_animate, image_cropper, shared_preferences

## Features
Take photos and record videos with the camera.
Pick multiple photos and video from the gallery.
Live preview.
Crop the images.

## Getting started

Add the `FlutterCam` dependency to your pubspec.yaml file.

### Android
Change the minimum Android sdk version to 21 (or higher) in your `android/app/build.gradle` file.

### iOS
It requires iOS 10.0 or higher.

## Example
```dart
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
```
