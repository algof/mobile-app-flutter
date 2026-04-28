import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'dart:io';

class CameraPreviewScreen extends StatefulWidget {
  
  final CameraDescription camera;
  
  const CameraPreviewScreen({super.key, required this.camera,});

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  // ================= CAMERA =================
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  // ================= GALLERY PICKER =================
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  // ================= CAMERA & GALLERY PICKER =================
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void navigateDashboard() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  Future<void> takePicture() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try{
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      await Gal.putImage(image.path, album: 'flutter_access_device_app');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Picture saved to Gallery/flutter_access_device_app')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal proses foto: $e')));
      }
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> pickFromGallery() async {
    if (_isUploading) return;
    setState(() => _isUploading = true);
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() => _selectedImage = File(file.path));
      }
      if (file == null) {
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gallery upload failed: $e')));
      }
      return;
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Access')),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          if (_isUploading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Uploading...', style: TextStyle(color: Colors.white))
                      ]
                    )
                  )
                )
              )
            )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'cameraGalleryBtn',
            onPressed: _isUploading ? null : pickFromGallery,
            // onPressed: () {},
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'cameraShutterBtn',
            onPressed: _isUploading ? null : takePicture,
            child: const Icon(Icons.camera),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'cameraHomeBtn',
            onPressed: () {navigateDashboard();},
            child: const Icon(Icons.home),
          )
        ],
      )
    );
  }
}
