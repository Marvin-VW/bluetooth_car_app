import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:provider/provider.dart';
import './bluetooth/bluetooth_class.dart';
import 'model_page_hor.dart';
import 'esp_cam.dart';
import 'distance_provider.dart';

class ControlPage extends StatefulWidget {
  final BluetoothConnector bluetooth;

  ControlPage({required this.bluetooth});

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool showCamera = true;
  double leftJoystickValue = 0.0;
  double rightJoystickValue = 0.0;
  bool _isExpanded = false;

  void _toggleBox() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

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
      body: Consumer<DistanceProvider>(
        builder: (context, distanceProvider, child) {
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  title: const Text('Control'),
                  backgroundColor: Colors.transparent,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.01,
                left: MediaQuery.of(context).size.width * 0.3,
                right: MediaQuery.of(context).size.width * 0.3,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 1,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: showCamera ? CarPage() : ImageStreamPage(),
                  ),
                ),
              ),
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        showCamera = !showCamera;
                      });
                      widget.bluetooth.sendBlMessage("Toggle View: \$showCamera");
                    },
                    color: Colors.grey[850],
                    child: const Text(
                      'Toggle Ansicht',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 40,
                child: GestureDetector(
                  onTap: _toggleBox,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: _isExpanded ? 220 : 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isExpanded
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.battery_full, color: Colors.green),
                        SizedBox(width: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Text('${(((distanceProvider.busVoltage - 6) / (7.4 - 6))*100).toInt().clamp(0, double.infinity)}%', style: TextStyle(color: Colors.white, fontSize: 15)),
                            SizedBox(width: 10),
                            Text('${distanceProvider.busVoltage} Volt', style: TextStyle(color: Colors.white, fontSize: 15)),
                            SizedBox(width: 10),
                            Text('${distanceProvider.current} A', style: TextStyle(color: Colors.white, fontSize: 15)),
                          ],
                        ),
                      ],
                    )
                        : Icon(Icons.info, color: Colors.white),
                  ),
                ),
              ),

            ],
          );
        },
      ),
    );
  }
}