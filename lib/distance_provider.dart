import 'package:flutter/material.dart';

class DistanceProvider with ChangeNotifier {
  int _leftDistance = 100;
  int _rightDistance = 100;
  int _frontDistance = 100;

  int get leftDistance => _leftDistance;
  int get rightDistance => _rightDistance;
  int get frontDistance => _frontDistance;

  void updateDistances(int left, int right, int front) {
    _leftDistance = left;
    _rightDistance = right;
    _frontDistance = front;
    notifyListeners();
  }
}