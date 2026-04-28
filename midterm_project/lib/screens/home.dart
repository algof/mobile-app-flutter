import 'package:midterm_project/screens/camera_preview.dart';
import 'package:midterm_project/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final logger = Logger();

  final FirestoreService firestoreService = FirestoreService();

  final nameTextController = TextEditingController();
  final companyTextController = TextEditingController();
  final phoneTextController = TextEditingController();
  String? selectedStatus;
  File? _selectedImage; // Untuk menyimpan foto baru yang dipilih
  String? _selectedImagePath; // Untuk menyimpan path foto lama saat edit
  final ImagePicker _picker = ImagePicker();

  void _clearControllers() {
    nameTextController.clear();
    companyTextController.clear();
    phoneTextController.clear();
    selectedStatus = '';
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      logger.e('Error picking image: $e');
    }
  }

  void showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 150,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Pilih Sumber Foto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToCameraPreview();
                    },
                    icon: Icon(Icons.camera_alt),
                    label: Text('Kamera'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.photo_library),
                    label: Text('Galeri'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void openNoteBox({
    String? docId,
    String? clientName,
    String? clientCompany,
    String? clientPhone,
    String? clientStatus,
    String? existingPhotoPath,
  }) {
    _selectedImage = null;
    _selectedImagePath = existingPhotoPath;

    if (docId != null) {
      nameTextController.text = clientName ?? '';
      companyTextController.text = clientCompany ?? '';
      phoneTextController.text = clientPhone ?? '';
      selectedStatus = clientStatus ?? '';
      _selectedImage = null;
      _selectedImagePath = existingPhotoPath;
    } else {
      _clearControllers();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            docId == null ? "Create client info" : "Edit client info",
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Photo Preview Section
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : _selectedImagePath != null &&
                            _selectedImagePath!.isNotEmpty
                      ? Image.file(File(_selectedImagePath!), fit: BoxFit.cover)
                      : Center(child: Text('Tidak ada foto')),
                ),
                SizedBox(height: 16),

                // Button Ambil/Ganti Foto
                ElevatedButton.icon(
                  onPressed: showImagePickerBottomSheet,
                  icon: Icon(Icons.photo_camera),
                  label: Text('Ambil/Ganti Foto'),
                ),
                SizedBox(height: 16),

                TextField(
                  decoration: InputDecoration(labelText: "Name"),
                  controller: nameTextController,
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(labelText: "Company"),
                  controller: companyTextController,
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(labelText: "Phone"),
                  controller: phoneTextController,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Status"),
                  initialValue: (selectedStatus ?? '').isEmpty ? null : selectedStatus,
                  items: ['Lead', 'Prospect', 'Active', 'Finished'].map((
                    status,
                  ) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedStatus = newValue!;
                    });
                  },
                  hint: Text("Pilih status"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearControllers();
                _selectedImage = null;
                _selectedImagePath = null;
              },
              child: Text('Batal'),
            ),
            MaterialButton(
              onPressed: () async {
                String? photoPath = _selectedImagePath;

                // Jika user pilih foto baru
                if (_selectedImage != null) {
                  try {
                    // Save foto ke local storage
                    photoPath = await firestoreService.saveClientPhoto(
                      docId ?? 'new_client',
                      _selectedImage!,
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving photo: $e')),
                    );
                    return; // Jangan lanjut save client
                  }
                }

                if (docId == null) {
                  await firestoreService.addClient(
                    nameTextController.text,
                    companyTextController.text,
                    phoneTextController.text,
                    selectedStatus,
                    photoPath ?? '',
                  );
                } else {
                  await firestoreService.updateClient(
                    docId,
                    nameTextController.text,
                    companyTextController.text,
                    phoneTextController.text,
                    selectedStatus,
                    _selectedImage != null ? photoPath : null,
                  );
                }

                if (!mounted) return;
                Navigator.pop(context);
                _clearControllers();
              },
              child: Text(docId == null ? "Create" : "Update"),
            ),
          ],
        );
      },
    );
  }

  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  Future<void> _navigateToCameraPreview() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraPreviewScreen(camera: cameras.first),
        ),
      );

      // Handle result dari camera_preview
      if (result != null && result is String) {
        setState(() {
          _selectedImage = File(result);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List Client"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 200,
                    color: Colors.blueAccent,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Logged in as\n${user?.email ?? '-'}",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 1.0),
                            ),
                          ),
                          ElevatedButton(
                            child: Text('Log out'),
                            onPressed: () {
                              Navigator.pop(context);
                              logout(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.account_circle),
          ),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openNoteBox();
          // navigateCameraPreview();
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getClient(),
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

              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

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
                    Text(noteStatus),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        openNoteBox(
                          docId: docId,
                          clientName: noteName,
                          clientCompany: noteCompany,
                          clientPhone: notePhone,
                          clientStatus: noteStatus,
                        );
                      },
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {
                        firestoreService.deleteClient(docId);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
