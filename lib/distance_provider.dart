import 'package:flutter/material.dart';

class DistanceProvider with ChangeNotifier {
  int _leftDistance = 100;
  int _rightDistance = 100;
  int _frontDistance = 100;
  double _busVoltage = 0.0;
  double _shuntVoltage = 0.0;
  double _current = 0.0;

  int get leftDistance => _leftDistance;
  int get rightDistance => _rightDistance;
  int get frontDistance => _frontDistance;
  double get busVoltage => _busVoltage;
  double get shuntVoltage => _shuntVoltage;
  double get current => _current;

  void updateDistances(int left, int right, int front, double busVoltage,
      double shuntVoltage, double current) {
    _leftDistance = left;
    _rightDistance = right;
    _frontDistance = front;
    _busVoltage = busVoltage;
    _shuntVoltage = shuntVoltage;
    _current = current;
    notifyListeners();
  }
}