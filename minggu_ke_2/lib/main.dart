import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Scaffold(
    appBar: AppBar(
      title: const Text("my first flutter app"),
      centerTitle: true,
      backgroundColor: Colors.blue[900],
    ),
    body: Center(
      child: Text(
        "ini aplikasi mobile pertama saya",
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: Colors.grey[600],
          fontFamily: 'IndieFlower',
        ),
        ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {},
      child: Text("click"),
    ),
  ),
));