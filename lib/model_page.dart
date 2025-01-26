import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'distance_provider.dart';

class CarPage extends StatefulWidget {
  @override
  _CarPageState createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  String selectedColor = "blue"; // Default color
  final List<String> carColors = [
    "black",
    "blue",
    "dark_blue",
    "dark_blue_grey",
    "dark_blue_metallic",
    "dark_dark_green",
    "dark_green_metallic",
    "dark_grey_green",
    "dark_purple",
    "dark_red",
    "gold_silver",
    "green",
    "light_blue",
    "light_blue_white",
    "light_light_orange",
    "light_orange",
    "light_purple",
    "light_red",
    "orange",
    "purple",
    "purple_blue",
    "red",
    "white",
    "yellow"
  ];

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
    // Call _animateSensorVisibility when the page loads
    _animateSensorVisibility();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parking"),
      ),
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
                  onTap: () {
                    _showColorPicker(context);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Car shadow
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.13,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.4,
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
                        top: MediaQuery.of(context).size.height * 0.1,
                        left: MediaQuery.of(context).size.width * 0.01,
                        child: Transform.rotate(
                          angle: 90 * 3.14159 / 180,
                          child: Image.asset(
                            "assets/top_down/$selectedColor.png",
                            width: MediaQuery.of(context).size.width * 1,
                            height: MediaQuery.of(context).size.height * 0.5,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Left sensor stack
                      Positioned(
                        top: MediaQuery.of(context).size.width * 0.7,
                        left: MediaQuery.of(context).size.width * 0.055,
                        child: Stack(
                          children: List.generate(
                            leftSensorVisibility.length,
                                (index) => Visibility(
                              visible: leftSensorVisibility[index],
                              child: Transform.rotate(
                                angle: 270 * pi / 180, // Rotate each sensor individually
                                child: Image.asset(
                                  "assets/sensors/left/left_sensor_$index.png",
                                  width: 120,
                                  height: 120,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Right sensor stack
                      Positioned(
                        top: MediaQuery.of(context).size.width * 0.7,
                        right: MediaQuery.of(context).size.width * 0.059,
                        child: Stack(
                          children: List.generate(
                            rightSensorVisibility.length,
                                (index) => Visibility(
                              visible: rightSensorVisibility[index],
                              child: Transform.rotate(
                                angle: 90 * pi / 180, // Rotate each sensor individually
                                child: Image.asset(
                                  "assets/sensors/right/right_sensor_$index.png",
                                  width: 120,
                                  height: 120,
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
                                width: 100,
                                height: 100,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Display distances from the DistanceProvider
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.64,
                        child:
                        _buildSensorDistances(context,
                            [distanceProvider.leftDistance, distanceProvider.rightDistance,distanceProvider.frontDistance, 100]
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

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose a Color"),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: carColors.length,
              itemBuilder: (context, index) {
                final colorName = carColors[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = colorName;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    child: Transform.rotate(
                      angle: 90 * 3.14159 / 180, // 90 degrees in radians
                      child: Image.asset(
                        "assets/top_down/$colorName.png",
                        scale: 3,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSensorDistances(BuildContext context, List<int> distances) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(10),
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
      margin: EdgeInsets.only(bottom: 5, top: 5),
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
}
