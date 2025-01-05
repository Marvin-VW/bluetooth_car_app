# Car Control App

A Flutter application designed to control various features of a connected car via Bluetooth. The app features light control, battery status display, power info, distance sensors, and navigation buttons for controlling the car and viewing its 3D model. It supports Bluetooth connectivity to interact with a car's hardware and allows for real-time monitoring of data like battery percentage, voltage, and sensor distances.

## Features

- **Bluetooth Connection**: Connect to a Bluetooth-enabled device (car) for remote control.
- **Battery and Power Info**: Displays the car's battery percentage, voltage, and power usage.
- **Light Control**: Control the car's headlights, taillights, and underglow lights.
- **Sensor Information**: View the car's sensor distances for obstacle detection.
- **Navigation**: Navigate to the control page and 3D model page to interact with the car in more detail.
- **Permissions**: Requests necessary Bluetooth permissions on the device for connection.

## Installation

1. **Clone the repository**:
    ```bash
    git clone https://github.com/Marvin-VW/bluetooth_car_app
    cd bluetooth_car_app
    ```

2. **Install dependencies**:
   Make sure you have Flutter installed. Run the following commands:
    ```bash
    flutter pub get
    ```

3. **Run the app**:
   Make sure you have an Android or iOS device connected, then run the app with:
    ```bash
    flutter run
    ```

## Usage

### Bluetooth Connectivity
- The app requires Bluetooth permissions. If permissions are not granted, a dialog will prompt the user to enable them.
- Once connected, the app will display real-time data such as the connection status and messages received from the car.

### Control the Car
- **Headlights**: Turn on/off the car's headlights.
- **Underglow**: Toggle the underglow lights of the car.
- **Taillights**: Control the car's taillights.

### View Information
- **Battery Info**: View the battery percentage, remaining charge, and power usage.
- **Voltage Info**: View the current voltage and current readings.
- **Sensor Distances**: View the distances detected by the car's sensors.

### Navigation
- Navigate to the **Control Page** to interact with the car's hardware features.
- Navigate to the **3D Model Page** to view a 3D model of the car.

## Bluetooth Permissions

The app requires Bluetooth and location permissions for scanning and connecting to Bluetooth devices. On Android, the app will prompt users to grant these permissions.

### Permissions Request

```dart
Permission.bluetooth.request();
```

If the user denies the permission, an alert dialog will appear prompting the user to enable Bluetooth permissions.

## Code Structure

- `home_page.dart`: The main page where users can control the car and view real-time data.
- `backend_service.dart`: Handles backend interactions (e.g., fetching sensor data, controlling the car).
- `control_page.dart`: A page for detailed control of the car.
- `model_page.dart`: A page displaying a 3D model of the car.
- `bluetooth/`: Contains the Bluetooth-related functionality, including device selection and connection management.
- `assets/`: Folder containing the car image used in the app interface.

## Dependencies

- `flutter_bluetooth_serial`: For Bluetooth communication.
- `permission_handler`: For requesting permissions.
- `open_settings_plus`: To open the settings page for Bluetooth permission management.