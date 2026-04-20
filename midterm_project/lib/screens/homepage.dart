import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:midterm_project/firestore.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  final nameTextController = TextEditingController();
  final companyTextController = TextEditingController();
  final phoneTextController = TextEditingController();
  String selectedStatus = '';

  void openNoteBox ({String? docId, String? existingName, String? existingCompany, String? existingPhone, required String existingStatus}) {
    if (docId != null) {
      nameTextController.text = existingName ?? '';
      companyTextController.text = existingCompany ?? '';
      phoneTextController.text = existingPhone ?? '';
      selectedStatus = existingStatus;
    }

    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? "Create client info" : "Edit client info"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Name"),
                  controller: nameTextController
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(labelText: "Company"),
                  controller: companyTextController
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(labelText: "Phone"),
                  controller: phoneTextController
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Status"),
                  initialValue: selectedStatus.isEmpty ? null : selectedStatus,
                  items: ['Lead', 'Prospect', 'Active', 'Finished'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(), 
                  onChanged: (newValue) {
                    setState(() {
                      selectedStatus = newValue!;
                    });
                  },
                  hint: Text("Pilih status")
                ),
              ],
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                if (docId == null){
                  firestoreService.addNote(nameTextController.text, companyTextController.text, phoneTextController.text, selectedStatus);
                }
                else{
                  firestoreService.updateNote(docId, nameTextController.text, companyTextController.text, phoneTextController.text, selectedStatus);
                }

                nameTextController.clear();
                companyTextController.clear();
                phoneTextController.clear();
                selectedStatus = '';
                
                Navigator.pop(context);
              },
              child: Text(docId == null ? "Create" : "Update")
            )
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("List Client"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openNoteBox(existingStatus: '');
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
          return ListView.builder(
            itemCount: notesList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = notesList[index];
              String docId = document.id;

              Map<String, dynamic> data = document.data() as Map<String, dynamic>;

              String noteName = data['name'];
              String noteCompany = data['company'];
              String notePhone = data['phone'];
              String noteStatus = data['status'];

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(noteName),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(noteCompany),
                    Text(notePhone),
                    Text(noteStatus)
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        openNoteBox(docId: docId, existingName: noteName, existingCompany: noteCompany, existingPhone: notePhone, existingStatus: noteStatus);
                      }, 
                      icon: const Icon(Icons.edit)
                    ),
                    IconButton(
                      onPressed: () {
                        firestoreService.deleteNote(docId);
                      },
                       icon: const Icon(Icons.delete)
                      )
                  ],
                ),
              );
            }
          );
        }
      ),
    );
  }
}
