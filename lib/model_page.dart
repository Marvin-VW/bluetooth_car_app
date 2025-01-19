import 'package:flutter/material.dart';
import 'package:o3d/o3d.dart';

class ModelPage extends StatefulWidget {
  final String title;

  const ModelPage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ModelPage> {
  // Controller for the 3D animation
  final O3DController controller = O3DController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => controller.cameraOrbit(20, 20, 5),
            icon: const Icon(Icons.change_circle),
          ),
          IconButton(
            onPressed: () => controller.cameraTarget(1.2, 1, 4),
            icon: const Icon(Icons.change_circle_outlined),
          ),
        ],
      ),
      body: O3D.asset(
        src: 'assets/models/car_model.glb',
        controller: controller,
      ),
    );
  }
}
