import 'package:flutter/material.dart';
import 'homepage.dart';
import 'control_page.dart';
import 'model_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retro Car Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: HomePage(),
    );
  }
}
