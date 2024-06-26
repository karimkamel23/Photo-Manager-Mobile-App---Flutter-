import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photomanager/pages/media_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaPicker(
        maxCount: 10,
        requestType: RequestType.common,
      ),
    );
  }
}
