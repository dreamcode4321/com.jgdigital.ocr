import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

void main() => runApp(OCRApp());

class OCRApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR App',
      home: OCRHomePage(),
    );
  }
}

class OCRHomePage extends StatefulWidget {
  @override
  _OCRHomePageState createState() => _OCRHomePageState();
}

class _OCRHomePageState extends State<OCRHomePage> {
  String? inputFolder;
  String? outputFolder;
  bool isProcessing = false;
  double progress = 0.0;
  List<String> imageFiles = [];

  Future<void> selectInputFolder() async {
    String? selected = await FilePicker.platform.getDirectoryPath();
    if (selected != null) {
      setState(() {
        inputFolder = selected;
        imageFiles = Directory(selected)
            .listSync()
            .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
            .map((f) => f.path)
            .toList();
      });
    }
  }

  Future<void> selectOutputFolder() async {
    String? selected = await FilePicker.platform.getDirectoryPath();
    if (selected != null) {
      setState(() {
        outputFolder = selected;
      });
    }
  }

  Future<void> processImages() async {
    if (inputFolder == null || outputFolder == null || imageFiles.isEmpty) return;
    setState(() {
      isProcessing = true;
      progress = 0.0;
    });
    const platform = MethodChannel('com.jgdigital.ocr/ocr');
    List<Map<String, String>> results = [];
    for (int i = 0; i < imageFiles.length; i++) {
      String text = await platform.invokeMethod('processImage', {
        'imagePath': imageFiles[i],
        'trainedDataPath': 'assets/tessdata/eng.traineddata',
      });
      results.add({'filename': imageFiles[i].split('/').last, 'text': text});
      setState(() {
        progress = (i + 1) / imageFiles.length;
      });
    }
    // Save results to Excel and Word
    await platform.invokeMethod('saveResults', {
      'results': results,
      'outputFolder': outputFolder,
    });
    setState(() {
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OCR App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: selectInputFolder,
              child: Text('Select Input Folder'),
            ),
            if (inputFolder != null) Text('Input: $inputFolder'),
            ElevatedButton(
              onPressed: selectOutputFolder,
              child: Text('Select Output Folder'),
            ),
            if (outputFolder != null) Text('Output: $outputFolder'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isProcessing ? null : processImages,
              child: Text('Start OCR'),
            ),
            if (isProcessing)
              Column(
                children: [
                  LinearProgressIndicator(value: progress),
                  Text('Processing: ${(progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
