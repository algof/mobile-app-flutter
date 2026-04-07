import 'package:minggu_ke_5/controllers/note_controllers.dart';
import 'package:minggu_ke_5/views/notes_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NoteDatabase.initialize();

  runApp(
      ChangeNotifierProvider(
        create: (context) => NoteDatabase(),
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NotesPage()
    );
  }
}
