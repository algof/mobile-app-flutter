import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';

class FirestoreService {
  final logger = Logger();

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

  // ================= PHOTO SERVICES =================
  // Get directory untuk simpan foto client
  Future<String> getClientPhotosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/client_photos');

    // Buat folder jika belum ada
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    return photoDir.path;
  }

  // Save foto dari File ke local storage dan return path
  Future<String> saveClientPhoto(String clientId, File imageFile) async {
    try {
      final photoDir = await getClientPhotosDirectory();
      final fileName =
          '${clientId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final photoPath = '$photoDir/$fileName';

      // Copy file ke local directory
      final savedImage = await imageFile.copy(photoPath);

      return savedImage.path;
    } catch (e) {
      logger.e('Error saving photo: $e'); // e = error level
      rethrow;
    }
  }

  // Delete foto dari local storage
  Future<void> deleteClientPhoto(String photoPath) async {
    try {
      if (photoPath.isEmpty) {
        return; // Jika kosong, skip
      }

      final photoFile = File(photoPath);

      // Cek apakah file exist sebelum delete
      if (await photoFile.exists()) {
        await photoFile.delete();
        logger.e('Photo deleted: $photoPath');
      }
    } catch (e) {
      logger.e('Error deleting photo: $e', error: e);
      rethrow;
    }
  }

  // ================= USER =================

  Future<void> setUser(String email, String password) {
    return users.doc(uid).set({
      'email': email,
      'password': hashString(password),
      'role': 'user',
    });
  }

  // ================= CLIENT =================

  Stream<QuerySnapshot> getClient() {
    return clients.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addClient(
    String name,
    String company,
    String phone,
    String status,
    String profilePath,
  ) {
    return clients.add({
      'name': name,
      'company': company,
      'phone': phone,
      'status': status,
      'profilePath': profilePath,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateClient(
    String id,
    String name,
    String company,
    String phone,
    String status,
    String? profilePath,
  ) {
    final updates = {
      'name': name,
      'company': company,
      'phone': phone,
      'status': status,
      'updatedAt': Timestamp.now(),
    };

    if (profilePath != null) {
      updates['profilePath'] = profilePath;
    }

    return clients.doc(id).update(updates);
  }

  Future<void> deleteClient(String id) async {
    var clientDoc = await clients.doc(id).get();
    var profilePath = clientDoc.data()?['profilePath'];
    await deleteClientPhoto(profilePath);

    return clients.doc(id).delete();
  }

  // ================= DOCUMENTS =================

  // 🔄 stream documents per client
  Stream<QuerySnapshot> getDocuments(String clientId) {
    return documents(
      clientId,
    ).orderBy('createdAt', descending: true).snapshots();
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
    return documents(
      clientId,
    ).doc(docId).update({'title': title, 'updatedAt': Timestamp.now()});
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
 * profilePath: String (lokasi untuk ngeload dari local storage)
 * createdAt: DateTime (Waktu data pertama kali dibuat)
 * updatetAt: DateTime (Waktu data diupdate/pertama kali dibuat)
 */
