import 'package:flutter/material.dart';
import 'package:minggu_ke_7_firebase_db/screens/home.dart';
import 'package:minggu_ke_7_firebase_db/homepage.dart';

class TabScreen extends StatelessWidget {
  const TabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Auth x CRUD'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Auth'),
              Tab(text: 'Notes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HomeScreen(),
            HomePage(),
          ],
        ),
      ),
    );
  }
}