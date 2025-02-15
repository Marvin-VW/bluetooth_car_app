import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'distance_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarPage extends StatefulWidget {
  @override
  _CarPageState createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  String selectedColor = "blue";

  // Define initial sensor visibility
  List<bool> leftSensorVisibility = [false, false, false];
  List<bool> rightSensorVisibility = [false, false, false];
  List<bool> frontSensorVisibility = [false, false, false];
  bool animation_running = true;

  final List<int> thresholds = [40, 30, 15];

  // Update visibility based on distances
  List<bool> updateVisibility(int distance) {
    List<bool> visibility = [
      distance > thresholds[1], // Far (60 < distance <= 100)
      distance > thresholds[2] && distance <= thresholds[1], // Medium (30 < distance <= 60)
      distance <= thresholds[2], // Close (distance <= 30)
    ];

    return visibility;
  }

  void _animateSensorVisibility() async {

    // Second phase: Toggle visibility sequentially (backward)
    for (int i = leftSensorVisibility.length - 1; i >= 0; i--) {
      await Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          leftSensorVisibility[i] = !leftSensorVisibility[i];
          rightSensorVisibility[i] = !rightSensorVisibility[i];
          frontSensorVisibility[i] = !frontSensorVisibility[i];
        });
      });
    }

    // First phase: Toggle visibility sequentially (forward)
    for (int i = 0; i < leftSensorVisibility.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          leftSensorVisibility[i] = !leftSensorVisibility[i];
          rightSensorVisibility[i] = !rightSensorVisibility[i];
          frontSensorVisibility[i] = !frontSensorVisibility[i];
        });
      });
    }

    // Second phase: Toggle visibility sequentially (backward)
    for (int i = leftSensorVisibility.length - 1; i >= 0; i--) {
      await Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          leftSensorVisibility[i] = !leftSensorVisibility[i];
          rightSensorVisibility[i] = !rightSensorVisibility[i];
          frontSensorVisibility[i] = !frontSensorVisibility[i];
        });
      });
    }

    animation_running = false;
  }

  @override
  void initState() {
    super.initState();
    _loadSavedColor();
    _animateSensorVisibility();
  }

  void _loadSavedColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedColor = prefs.getString('selectedColor') ?? "blue";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<DistanceProvider>(
        builder: (context, distanceProvider, child) {
          // Update visibility based on distances from the DistanceProvider

          if (animation_running == false) {
            leftSensorVisibility =
            updateVisibility(distanceProvider.leftDistance);
            rightSensorVisibility =
            updateVisibility(distanceProvider.rightDistance);
            frontSensorVisibility =
            updateVisibility(distanceProvider.frontDistance);
          }

          return Column(
            children: [
              Expanded(
                child: GestureDetector(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Car shadow
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.28,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 30,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Car image
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.0475,
                        child: Transform.rotate(
                          angle: 90 * 3.14159 / 180,
                          child: Image.asset(
                            "assets/top_down/$selectedColor.png",
                            width: MediaQuery.of(context).size.height * 0.65,
                            height: MediaQuery.of(context).size.width * 0.5,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Left sensor stack
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.42,
                        left: MediaQuery.of(context).size.height * 0.11,
                        child: Stack(
                          children: List.generate(
                            leftSensorVisibility.length,
                                (index) => Visibility(
                              visible: leftSensorVisibility[index],
                              child: Transform.rotate(
                                angle: 270 * pi / 180, // Rotate each sensor individually
                                child: Image.asset(
                                  "assets/sensors/left/left_sensor_$index.png",
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Right sensor stack
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.42,
                        right: MediaQuery.of(context).size.height * 0.11,
                        child: Stack(
                          children: List.generate(
                            rightSensorVisibility.length,
                                (index) => Visibility(
                              visible: rightSensorVisibility[index],
                              child: Transform.rotate(
                                angle: 90 * pi / 180, // Rotate each sensor individually
                                child: Image.asset(
                                  "assets/sensors/right/right_sensor_$index.png",
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Front sensor stack
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.04,
                        child: Stack(
                          children: List.generate(
                            frontSensorVisibility.length,
                                (index) => Visibility(
                              visible: frontSensorVisibility[index],
                              child: Image.asset(
                                "assets/sensors/front/front_sensor_$index.png",
                                width: 65,
                                height: 65,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
