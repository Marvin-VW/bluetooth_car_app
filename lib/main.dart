import 'package:flutter/material.dart';
import 'homepage.dart';
import 'control_page.dart';
import 'model_page.dart';

void main() {
  runApp(BluetoothCarControl());
}

class BluetoothCarControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nissan Car Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: HomePage(),
    );
  }
}
