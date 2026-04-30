import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCapturing = false;

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

  Future<void> _takePicture() async {
    try {
      // Prevent multiple captures
      if (_isCapturing) return;
      
      setState(() {
        _isCapturing = true;
      });

      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      if (!mounted) return;
      
      // Return image path ke home_screen
      Navigator.pop(context, image.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: $e')),
        );
      }
      
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _pickPicture(ImageSource source) async {
    try {
      // Prevent multiple captures
      if (_isCapturing) return;
      
      setState(() {
        _isCapturing = true;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (!mounted) return;
      
      // Return image path ke home_screen
      if (image != null) {
        Navigator.pop(context, image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking picture: $e')),
        );
      }
      
      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Photo'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: 
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _isCapturing ? null : _takePicture,
            backgroundColor: Colors.blueAccent,
            child: _isCapturing
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Icon(Icons.camera),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _isCapturing ? null : () {_pickPicture(ImageSource.gallery);}, 
            backgroundColor: Colors.blueAccent,
            child: _isCapturing
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Icon(Icons.photo_library),
          ),
        ],
      ),
      // FloatingActionButton(
      //   onPressed: _isCapturing ? null : _takePicture,
      //   backgroundColor: Colors.blueAccent,
      //   child: _isCapturing
      //       ? const CircularProgressIndicator(
      //           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      //         )
      //       : const Icon(Icons.camera),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}