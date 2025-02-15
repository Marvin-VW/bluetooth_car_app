import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import './bluetooth/bluetooth_class.dart';
import 'model_page_hor.dart';
import 'esp_cam.dart';

class ControlPage extends StatefulWidget {
  final BluetoothConnector bluetooth;

  // Constructor to accept the Bluetooth instance.
  ControlPage({required this.bluetooth});

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool showCamera = true;
  double leftJoystickValue = 0.0;
  double rightJoystickValue = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          /// **AppBar**
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: const Text('Control'),
              backgroundColor: Colors.transparent,
            ),
          ),

          /// **Camera or Distance Sensor View (Overlapping the AppBar slightly)**
          Positioned(
            top: MediaQuery
                .of(context)
                .size
                .height * 0.01, // Slightly overlaps AppBar
            left: MediaQuery
                .of(context)
                .size
                .width * 0.3,
            right: MediaQuery
                .of(context)
                .size
                .width * 0.3,
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.4,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 1,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: showCamera
                    ? CarPage() // Camera page
                    : ImageStreamPage(), // Distance sensor page
              ),
            ),
          ),

          /// **Left Joystick**
          Positioned(
            left: 20,
            bottom: 70,
            child: Joystick(
              listener: (StickDragDetails details) {
                widget.bluetooth.sendBlMessage("Left Joystick: ${details.y}");
              },
              mode: JoystickMode.vertical,
            ),
          ),

          /// **Right Joystick**
          Positioned(
            right: 20,
            bottom: 70,
            child: Joystick(
              listener: (StickDragDetails details) {
                widget.bluetooth.sendBlMessage("Right Joystick: ${details.x}");
              },
              mode: JoystickMode.horizontal,
            ),
          ),

          /// **Toggle Button**
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: MaterialButton(
                onPressed: () {
                  setState(() {
                    showCamera = !showCamera;
                  });
                  widget.bluetooth.sendBlMessage("Toggle View: $showCamera");
                },
                color: Colors.grey[850],
                child: const Text(
                  'Toggle Ansicht',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
