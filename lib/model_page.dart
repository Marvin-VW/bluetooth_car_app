import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('3D Modell')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Scheinwerfer an/aus'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Kamera Ansicht'),
                ),
              ],
            ),
            // 3D Modell einfügen
            Container(
              width: 300,
              height: 300,
              child: ModelViewer(
                src: 'assets/models/car_model.glb', // Pfad zu deinem Modell
                ar: true,
                autoRotate: true,
                cameraControls: true,
                backgroundColor: Colors.grey,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Abstand links 1'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Abstand links 2'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Abstand rechts 1'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Abstand rechts 2'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Rückleuchten an/aus'),
            ),
          ],
        ),
      ),
    );
  }
}
