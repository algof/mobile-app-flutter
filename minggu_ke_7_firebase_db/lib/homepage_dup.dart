import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

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

  final FirestoreService firestoreService = FirestoreService();

  void openNoteBox({String? docId, String? existingTitle, String? existingNote, String? existingLabel, DateTime? existingDate}) async {
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
              title: Text(docId == null ? "Create new Note" : "Edit Note"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: "Title"),
                    controller: titleTextController,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: "Content"),
                    controller: contentTextController,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: "Label"),
                    controller: labelTextController,
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Date",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
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
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDate == null
                                    ? "Select date"
                                    : "${selectedDate!.day.toString().padLeft(2, '0')}/"
                                    "${selectedDate!.month.toString().padLeft(2, '0')}/"
                                    "${selectedDate!.year}",
                                style: TextStyle(
                                  color: selectedDate == null ? Colors.grey : Colors.black,
                                ),
                              ),
                              const Icon(Icons.calendar_today, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // TextButton(
                  //   onPressed: () async {
                  //     DateTime? picked = await showDatePicker(
                  //       context: context,
                  //       initialDate: DateTime.now(),
                  //       firstDate: DateTime(2000),
                  //       lastDate: DateTime(2100),
                  //     );
                  //
                  //     if (picked != null) {
                  //       setStateDialog(() {
                  //         selectedDate = picked;
                  //       });
                  //     }
                  //   },
                  //   child: Text(
                  //     selectedDate == null
                  //         ? "Pick Date"
                  //         : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  //   ),
                  // ),
                ],
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
                        selectedDate ?? existingDate ?? DateTime.now()
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
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            selectedDate = null;
          });
          openNoteBox();
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                String docId = document.id;

                Map<String, dynamic> data =
                document.data() as Map<String, dynamic>;
                String noteTitle = data['title'];
                String noteContent = data['content'];
                String noteLabel = data['label'];
                DateTime noteDate = (data['selectedDate'] as Timestamp).toDate();

                return ListTile(
                  title: Text(noteTitle),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(noteContent),
                      Text(noteLabel),
                      Text(
                        "${noteDate.day.toString().padLeft(2, '0')}/"
                            "${noteDate.month.toString().padLeft(2, '0')}/"
                            "${noteDate.year}",
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          openNoteBox(
                            docId: docId,
                            existingNote: noteContent,
                            existingTitle: noteTitle,
                            existingLabel: noteLabel,
                            existingDate: noteDate,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          firestoreService.deleteNote(docId);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Text("No data");
          }
        },
      ),
    );
  }
}