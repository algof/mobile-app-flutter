import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class FirestoreService {

  String hashString(String input) {
    final bytes = utf8.encode(input); // ubah ke bytes
    final digest = sha256.convert(bytes); // hashing

    return digest.toString();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get clients =>
      users.doc(uid).collection('clients');

  // 🔥 documents berdasarkan clientId
  CollectionReference<Map<String, dynamic>> documents(String clientId) =>
      clients.doc(clientId).collection('documents');

  // ================= USER =================

  Future<void> setUser(String email, String password) {
    return users.doc(uid).set({
      'email': email,
      'password': hashString(password),
      'role': 'user'
    });
  }

  // ================= CLIENT =================

  Stream<QuerySnapshot> getClient() {
    return clients.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addClient(String name, String company, String phone, String status) {
    return clients.add({
      'name': name,
      'company': company,
      'phone': phone,
      'status': status,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now()
    });
  }

  Future<void> updateClient(String id, String name, String company, String phone, String status) {
    return clients.doc(id).update({
      'name': name,
      'company': company,
      'phone': phone,
      'status': status,
      'updatedAt': Timestamp.now()
    });
  }

  Future<void> deleteClient(String id) {
    return clients.doc(id).delete();
  }

  // ================= DOCUMENTS =================

  // 🔄 stream documents per client
  Stream<QuerySnapshot> getDocuments(String clientId) {
    return documents(clientId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ➕ add document
  Future<void> addDocument(String clientId, String title) {
    return documents(clientId).add({
      'title': title,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  // ✏️ update document
  Future<void> updateDocument(String clientId, String docId, String title) {
    return documents(clientId).doc(docId).update({
      'title': title,
      'updatedAt': Timestamp.now(),
    });
  }

  // ❌ delete document
  Future<void> deleteDocument(String clientId, String docId) {
    return documents(clientId).doc(docId).delete();
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