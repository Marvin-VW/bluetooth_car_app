// backend_service.dart

class BackendService {
  // Placeholder for sensor distances
  List<int> distances = [20, 15, 10, 5];

  // Placeholder for light status
  bool isLightOn = false;

  // Method to toggle light status (example)
  void toggleLight() {
    isLightOn = !isLightOn;
  }

  // Method to update distances (example)
  void updateDistances(List<int> newDistances) {
    distances = newDistances;
  }
}

final backendService = BackendService(); // Singleton instance
