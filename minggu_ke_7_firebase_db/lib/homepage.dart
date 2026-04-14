import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final titleTextController = TextEditingController();
  final contentTextController = TextEditingController();
  final labelTextController = TextEditingController();

  DateTime? selectedDate;

  final FirestoreService firestoreService = FirestoreService();

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void openNoteBox({
    String? docId,
    String? existingTitle,
    String? existingNote,
    String? existingLabel,
    DateTime? existingDate,
  }) {
    if (docId != null) {
      titleTextController.text = existingTitle ?? '';
      contentTextController.text = existingNote ?? '';
      labelTextController.text = existingLabel ?? '';
      selectedDate = existingDate;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(docId == null ? "Create Note" : "Edit Note"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleTextController,
                      decoration: const InputDecoration(labelText: "Title"),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: contentTextController,
                      decoration: const InputDecoration(labelText: "Content"),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: labelTextController,
                      decoration: const InputDecoration(labelText: "Label"),
                    ),
                    const SizedBox(height: 10),

                    // DATE PICKER UI
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Date",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),

                        InkWell(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              setStateDialog(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate == null
                                      ? "Select date"
                                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                                ),
                                const Icon(Icons.calendar_today, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    if (docId == null) {
                      firestoreService.addNote(
                        titleTextController.text,
                        contentTextController.text,
                        labelTextController.text,
                        selectedDate ?? DateTime.now(),
                      );
                    } else {
                      firestoreService.updateNote(
                        docId,
                        titleTextController.text,
                        contentTextController.text,
                        labelTextController.text,
                        selectedDate ?? DateTime.now(),
                      );
                    }

                    titleTextController.clear();
                    contentTextController.clear();
                    labelTextController.clear();
                    selectedDate = null;

                    Navigator.pop(context);
                  },
                  child: Text(docId == null ? "Create" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            selectedDate = null;
          });
          titleTextController.clear();
          contentTextController.clear();
          labelTextController.clear();
          openNoteBox();
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List notesList = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: notesList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = notesList[index];
              String docId = document.id;

              Map<String, dynamic> data =
              document.data() as Map<String, dynamic>;

              String noteTitle = data['title'];
              String noteContent = data['content'];
              String noteLabel = data['label'];

              DateTime noteDate =
              (data['selectedDate'] as Timestamp).toDate();

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        noteTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(noteContent),
                      Text(noteLabel),

                      const Spacer(),

                      Text(
                        "${noteDate.day.toString().padLeft(2, '0')}/"
                            "${noteDate.month.toString().padLeft(2, '0')}/"
                            "${noteDate.year}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () {
                              openNoteBox(
                                docId: docId,
                                existingTitle: noteTitle,
                                existingNote: noteContent,
                                existingLabel: noteLabel,
                                existingDate: noteDate,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            onPressed: () {
                              firestoreService.deleteNote(docId);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}