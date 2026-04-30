import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import 'package:minggu_ke_10/services/ocr_service.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  final CameraDescription camera;
  
  const HomeScreen({
    super.key,
    required this.camera,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _ocrResult = '';
  bool _isProcessing = false;
  final OCRService _ocrService = OCRService();

  /// Navigate ke camera dan process image
  Future<void> _takePictureAndProcess() async {
    try {
      // Navigate ke camera screen
      final imagePath = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(camera: widget.camera),
        ),
      );

      // Jika user cancel
      if (imagePath == null) return;

      // Start processing
      _processImage(imagePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Process image dengan OCR
  Future<void> _processImage(String imagePath) async {
    setState(() {
      _isProcessing = true;
      _ocrResult = 'Processing image...';
    });

    try {
      final result = await _ocrService.recognizeTextFromImage(imgPath: imagePath);
      
      setState(() {
        _ocrResult = result.isEmpty ? 'No text detected' : result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _ocrResult = 'Error: $e';
        _isProcessing = false;
      });
    }
  }

  /// Clear result
  void _clearResult() {
    setState(() {
      _ocrResult = '';
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algof OCR: Image to Text'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'OCR Result',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),

              // Result Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: _isProcessing
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Processing image...',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : _ocrResult.isEmpty
                          ? Center(
                              child: Text(
                                'Hasil OCR akan muncul disini\n\nKlik tombol dibawah untuk mengambil foto',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _ocrResult,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      height: 1.6,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  // Clear button di bawah text
                                  if (!_isProcessing)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(top: 20.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: _clearResult,
                                          icon: const Icon(Icons.clear),
                                          label: const Text('Clear Result'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
      // ✅ GANTI FAB dengan BottomAppBar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.blueAccent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Empty space for balance
              const SizedBox(width: 48),
              
              // Camera Button (di tengah/center)
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _takePictureAndProcess,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              
              // Empty space for balance
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}