import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'control_page.dart';
import 'model_page.dart';
import 'backend_service.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import './bluetooth/select_bonded_device_page.dart';
import './bluetooth/bluetooth_class.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> initializeApp() async {
    // Simulate a loading process (e.g., loading assets, fetching data)
    await Future.delayed(Duration(seconds: 3)); // Replace with real initialization logic
  }
  final String carImage = 'assets/car_image2.png';
  bool underglow = false;
  BluetoothConnector? bl;
  late Timer _timer;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _device_selected_by_user = false;
  String _receivedMessage = '';

  @override
  void initState() {
    super.initState();

    // Initialize the BluetoothConnector
    if (Platform.isAndroid) {
      bl = BluetoothConnector();
    }

    // Start listening for Bluetooth messages
    bl?.receiveBlMessage();

    // Start a timer to check connection status every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (bl != null) {
        final connected = bl!.isConnected;
        final is_connecting = bl!.isConnected;
        final receivedMessage = bl!.receivedMessage;
        if (connected != _isConnected) {
          setState(() {
            _isConnected = connected;
          });
        }
        if (is_connecting != _isConnecting) {
          setState(() {
            _isConnecting = is_connecting;
          });
        }
        if (receivedMessage != _receivedMessage) {
          setState(() {
            _receivedMessage = receivedMessage;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // Cancel the timer to avoid memory leaks
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Permission.bluetooth.request();

    return Scaffold(
      backgroundColor: Colors.white10,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.width * 0.03),
              // Stack for overlaying the connection widget on the image
              Center(
                child: Stack(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 300,
                        minWidth: 300,
                      ),
                      child: Image.asset(
                        carImage,
                        height: 300,
                      ),
                    ),
                    Positioned(
                      top: 230,
                      child: _buildConnection(context, _isConnected, _isConnecting, _device_selected_by_user,  () async {
                        await handleConnectRequest();
                      }),
                    ),
                  ],
                ),
              ),

              // Battery and Lock Status Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBatteryInfoBox(context),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  _buildVoltageInfoBox(context),
                ],
              ),
              SizedBox(height: 20),
              // Light Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLightControl(context),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSensorDistances(context, backendService.distances),
                ],
              ),
              SizedBox(height: 20),
              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavigationButton(context, 'Steuerung', ControlPage(bluetooth: bl!,)),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  _buildNavigationButton(context, '3D Modell', ModelPage()),
                ],
              ),
              Text(
                _receivedMessage,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }


Future handleConnectRequest() async {
    await Permission.bluetoothScan.status.then((value) async {
      debugPrint("-------!${value.isGranted}!-------");
      if (value.isGranted) {
        debugPrint('Bluetooth permission granted');
        connectToBlDevice();
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return requestBluetoothDialog(context);
            });
      }
    });
  }

  AlertDialog requestBluetoothDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Bluetooth Permission'),
      content: const Text(
        'This app requires bluetooth permission to connect to the device, please allow location and nearby devices permission to continue.',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            await openAppSettings().then((value) async {
              Navigator.of(context).pop();
              await Permission.bluetoothScan.status.then((value) {
                if (value.isGranted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        'Bluetooth permission granted, please try again.',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 24,
                        ),
                      )));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        'Bluetooth permission is required to connect to the device.',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 24,
                        ),
                      )));
                }
              });
            });
          },
          child: const Text(
            'Open Settings',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }



void connectToBlDevice() async {
    final BluetoothDevice? device = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const SelectBondedDevicePage(checkAvailability: false);
        },
      ),
    );

    if (device == null) {
      debugPrint('No device selected');
      return;
    } else {
      _device_selected_by_user = true;
      bl!.connectToDevice(device);
    }
  }

  Widget blMessageButton(
      {required String message, required String buttonText}) {
    // Bluetooth Connection is only available on Android
    if (!Platform.isAndroid) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Bluetooth is not available on this device',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
            ),
          ),
        ),
      );
    }
    return ElevatedButton(
      onPressed: () {
        if (bl != null) {
          bl!.sendBlMessage(message);
        }
      },
      child: Text(
        buttonText,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
        ),
      ),
    );
  }



  // Battery Info Box
  Widget _buildBatteryInfoBox(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.425,
        minHeight: MediaQuery.of(context).size.width * 0.4,
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Battery',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${backendService.distances[0]} min Remaining', // Replace with actual remaining time if available
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Text(
                      '${backendService.distances[0]}%', // Battery percentage
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '7.3 Wh', // Placeholder for battery kWh
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${backendService.distances[1]} Km', // Distance
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Voltage Info Box
  Widget _buildVoltageInfoBox(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.425,
        minHeight: MediaQuery.of(context).size.width * 0.4,
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Power',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Voltage',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '5V',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Current',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '1.3 A',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

// Light Control Button
  Widget _buildLightControl(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 70,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row( // Use Row for multiple buttons in a horizontal layout
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            ),
            onPressed: () {
              // Add your functionality here
            },
            child: Text('Headlights'),
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            ),
            onPressed: () {
              underglow = !underglow;

              if (underglow == true) {
                bl!.sendBlMessage("underglow on");
              } else {
                bl!.sendBlMessage("underglow off");
              }
            },
            child: Text('Underglow'),
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            ),
            onPressed: () {
              // Add your functionality here
            },
            child: Text('Taillights'),
          ),
        ],
      ),
    );
  }


  Widget _buildConnection(BuildContext context, bool isConnected, bool isConnecting, bool device_selected_by_user, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Callback for handling button press
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        //height: MediaQuery.of(context).size.width * 0.12,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              size: 22,
              isConnected ? Icons.wifi_outlined : (isConnecting && device_selected_by_user ? Icons.sync : Icons.wifi_off),
              color: isConnected
                  ? Colors.green
                  : (isConnecting && device_selected_by_user ? Colors.yellow : Colors.red),
            ),
            SizedBox(width: 10), // Adds spacing between the icon and text
            Text(
              isConnected
                  ? 'Connected'
                  : (isConnecting && device_selected_by_user ? 'Connecting ...' : 'Disconnected'),
              style: TextStyle(
                fontSize: 18,
                color: isConnected
                    ? Colors.green
                    : (isConnecting && device_selected_by_user ? Colors.yellow : Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSensorDistances(BuildContext context, List<int> distances) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (int i = 0; i < distances.length; i += 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSensorBox(distances[i]),
                if (i + 1 < distances.length) _buildSensorBox(distances[i + 1]),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSensorBox(int distance) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$distance cm',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  _buildNavigationButton(BuildContext context, String label, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () {
        if (label == 'Steuerung') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ControlPage(bluetooth: bl!),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }




}
