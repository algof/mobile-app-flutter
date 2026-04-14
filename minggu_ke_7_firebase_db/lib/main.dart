import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:minggu_ke_7_firebase_db/homepage.dart';

import 'firebase_options.dart';

import 'package:minggu_ke_7_firebase_db/screens/home.dart';
import 'package:minggu_ke_7_firebase_db/screens/login.dart';
import 'package:minggu_ke_7_firebase_db/screens/register.dart';
import 'package:minggu_ke_7_firebase_db/screens/tab_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget { // CRUD Note
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: HomePage(),
//     );
//   }
// }

class MyApp extends StatelessWidget { // Authentication
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: 'login', routes: {
      'home': (context) => const HomeScreen(),
      'login': (context) => const LoginScreen(),
      'register': (context) => const RegisterScreen(),
      'tabs': (context) => const TabScreen(),
    });
  }
}