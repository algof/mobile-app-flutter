import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{

  final CollectionReference notes = FirebaseFirestore.instance.collection('notes');

  //create new note
  Future<void> addNote(String title, String content, String label, DateTime selectedDate) {
    return notes.add({
      'title': title,
      'content': content,
      'label': label,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'selectedDate': Timestamp.fromDate(selectedDate),
    });
  }

  //fetch all notes
  Stream<QuerySnapshot> getNotes() {
    return notes.orderBy('createdAt', descending: true).snapshots();
  }

  //update notes
  Future<void> updateNote(String id, String title, String content, String label, DateTime selectedDate) {
    return notes.doc(id).update({
      'title': title,
      'content': content,
      'label': label,
      'updatedAt': Timestamp.now(),
      'selectedDate': Timestamp.fromDate(selectedDate),
    });
  }

  //delete notes
  Future<void> deleteNote(String id) {
    return notes.doc(id).delete();
  }

}