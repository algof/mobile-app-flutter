import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';

class CameraPreviewScreen extends StatefulWidget {
  
  final CameraDescription camera;
  
  const CameraPreviewScreen({super.key, required this.camera,});

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Access')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'cameraGalleryBtn',
            // onPressed: _isUploading ? null : pickFromGallery,
            onPressed: () {},
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'cameraShutterBtn',
            onPressed: takePicture,
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
