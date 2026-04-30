import 'package:minggu_ke_10/screens/home_screen.dart';
import 'package:minggu_ke_10/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: 'home', routes: {
      'home': (context) => const HomeScreen(),
      'camera': (context) => CameraScreen(camera: camera),
    });
  }
}