import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class ControlPage extends StatefulWidget {
  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool showCamera = true;
  Offset leftJoystickValue = Offset.zero;
  Offset rightJoystickValue = Offset.zero;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]); // Querformat fixieren
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // Orientierung zurücksetzen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Steuerung'), backgroundColor: Colors.black,),
      body: Stack(
        children: [
          // Kamera-/Abstandssensoransicht in der Mitte, etwas nach oben verschoben
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15, // Nach oben verschoben
            left: MediaQuery.of(context).size.width * 0.2,
            right: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  showCamera ? 'Kamera Feed' : 'Abstandssensoren',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
          // Linker Joystick in der linken unteren Ecke
          Positioned(
            left: 20,
            bottom: 70,
            child: Joystick(
              listener: (StickDragDetails details) {
                setState(() {
                  //leftJoystickValue = details.offset;
                });
              },
              mode: JoystickMode.all,
              //size: 80, // Verkleinerte Joystick-Größe
            ),
          ),
          // Rechter Joystick in der rechten unteren Ecke
          Positioned(
            right: 20,
            bottom: 70,
            child: Joystick(
              listener: (StickDragDetails details) {
                setState(() {
                  //rightJoystickValue = details.offset;
                });
              },
              mode: JoystickMode.all,
              //size: 80, // Verkleinerte Joystick-Größe
            ),
          ),
          // Toggle Button zentriert unten

          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: MaterialButton(
                onPressed: () {
                  setState(() {
                    showCamera = !showCamera;
                  });
                },
                child: Text('Toggle Ansicht'),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
