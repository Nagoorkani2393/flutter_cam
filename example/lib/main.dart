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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterCam(
        cameraDescriptions: flutterCamDescription,
        onUploadTap: (files) {},
        onBackTap: () {},
      ),
    );
  }
}
