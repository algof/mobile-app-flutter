import 'package:midterm_project/screens/camera_preview.dart';
import 'package:midterm_project/screens/register.dart';
import 'package:midterm_project/screens/login.dart';
import 'package:midterm_project/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'firebase_options.dart';
import 'package:gal/gal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: 'login', routes: {
      'home': (context) => const HomePage(),
      'login': (context) => const LoginScreen(),
      'register': (context) => const RegisterScreen(),
      'camera': (context) => CameraPreviewScreen(camera: camera),
    });
  }
}