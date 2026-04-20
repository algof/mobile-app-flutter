import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  final CollectionReference notes = FirebaseFirestore.instance.collection('notes');

  //fetch all notes
  Stream<QuerySnapshot> getNotes() {
    return notes.orderBy('createdAt', descending: true).snapshots();
  }

  //create new note
  Future<void> addNote(String name, String company, String phone, String status) {
    return notes.add({
      'name': name,
      'company': company,
      'phone': phone,
      'status': status,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now()
    });
  }

  Future<void> updateNote(String id, String name, String company, String phone, String status) {
    return notes.doc(id).update({
      'name': name,
      'company': company,
      'phone': phone,
      'status': status,
      'updatedAt': Timestamp.now()
    });
  }

  //delete notes
  Future<void> deleteNote(String id) {
    return notes.doc(id).delete();
  }

}

/**
 * Table Client format data
 * id: String (Document ID)
 * name: String (Nama Lengkap)
 * company: String (Nama Perusahaan/Instansi)
 * phone: String (Nomor WhatsApp/Telepon)
 * status: String (Misal: Lead, Prospect, Active, Finished)
 * createdAt: DateTime (Waktu data pertama kali dibuat)
 * profilePath: String (lokasi untuk ngeload dari Cloudinary)
 */