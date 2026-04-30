import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class OCRService {
  Future<String> recognizeTextFromImage({required String imgPath}) async {
    /// Create an instance of TextRecognizer
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    /// Process image
    final image = InputImage.fromFile(File(imgPath));
    final recognized = await textRecognizer.processImage(image);

    return recognized.text;
  }
}