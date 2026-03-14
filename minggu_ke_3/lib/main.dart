import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas Minggu ke-3',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context){
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double screenHeight = mediaQueryData.size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My first app',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFFFE082),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
              padding: EdgeInsets.all(20.0),
              color: Colors.lightBlue[100],
              child: Center(
                child: Image.network(
                  'https://picsum.photos/200',
                  fit: BoxFit.cover,
                  width: 500,
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
            padding: EdgeInsets.all(20.0),
            color: Colors.pink[200],
            child: Text(
                'What image is that?',
                style: TextStyle(fontSize: 16)
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.yellow[200],
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(children: [Icon(Icons.food_bank), Text("Food")]),
                Column(children: [Icon(Icons.beach_access_rounded), Text("Scenery")]),
                Column(children: [Icon(Icons.person), Text("People")]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
