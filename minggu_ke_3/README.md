# minggu_ke_3

Tugas mobile programming minggu ke-3

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Widget Tree

```txt
runApp
└── MyApp
    └── MaterialApp
        ├── title: "Tugas Minggu ke-3"
        ├── theme: ThemeData
        │   └── ColorScheme.fromSeed
        └── home
            └── MyHomePage
                └── Scaffold
                    ├── AppBar
                    │   └── Text("My First App")
                    │
                    └── Body
                        └── Column
                            ├── AspectRatio
                            │   └── Container
                            │       └── Center
                            │           └── Image.network
                            │
                            ├── Container
                            │   └── Text("What image is that?")
                            │
                            ├── Container
                            │   └── Row
                            │       ├── Column
                            │       │   ├── Icon(Icons.food_bank)
                            │       │   └── Text("Food")
                            │       │
                            │       ├── Column
                            │       │   ├── Icon(Icons.terrain)
                            │       │   └── Text("Scenery")
                            │       │
                            │       └── Column
                            │           ├── Icon(Icons.people)
                            │           └── Text("People")
                            │
                            └── CounterCard (StatefulWidget)
                                └── Container
                                    └── Row
                                        ├── Text("Counter here: $_counter")
                                        └── Container
                                            └── IconButton
                                                └── Icon(Icons.add)
```