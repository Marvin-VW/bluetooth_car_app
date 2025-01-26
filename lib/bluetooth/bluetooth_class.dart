import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothConnector {
  BluetoothDevice? connectedDevice;
  BluetoothConnection? connection;
  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);
  bool isDisconnecting = false;
  String serverName = '';
  String receivedMessage = '';
  int value1 = 100;
  int value2 = 100;
  int value3 = 100;

  /// Connect to a Bluetooth device (only if not already connected)
  void connectToDevice(BluetoothDevice device) async {
    if (device == connectedDevice && isConnected) {
      debugPrint('Already connected to ${device.name}');
      return;
    }
    connectedDevice = device;
    serverName = device.name ?? "Unknown";

    try {
      debugPrint('Connecting to ${device.name}...');
      connection = await BluetoothConnection.toAddress(device.address);
      debugPrint('Connected to ${device.name}');
      isConnecting = false;
      isDisconnecting = false;

      // Listen for incoming data
      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          debugPrint('Disconnected locally.');
        } else {
          debugPrint('Disconnected remotely.');
        }
        isConnecting = true;
      });
    } catch (error) {
      debugPrint('Connection error: $error');
      isConnecting = true;
    }
  }

  /// Send a message over the Bluetooth connection
  void sendBlMessage(String message) async {
    if (connection == null || !isConnected) {
      debugPrint('No connection established.');
      return;
    }

    final text = message.trim();
    if (text.isNotEmpty) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode("$text\r\n")));
        await connection!.output.allSent;
        debugPrint('Sent: $text');
      } catch (e) {
        debugPrint('Error while sending: $e');
      }
    }
  }

  /// Handle incoming data from the Bluetooth connection
  void _onDataReceived(Uint8List data) {
    try {
      // Clean data of backspace characters
      final cleanedData = _processBackspaces(data);

      // Decode and process the message
      final message = String.fromCharCodes(cleanedData).trim();
      if (message.isNotEmpty) {
        debugPrint('Received: $message');

        // Split the message by commas and parse each value into an integer
        List<int> parsedValues = message
            .replaceAll(' ', '') // Remove spaces
            .split(',') // Split by commas
            .map((value) => int.tryParse(value) ?? 0) // Convert to integer, default to 0 on error
            .toList();

        if (parsedValues.length >= 3) {
          value1 = parsedValues[0];
          value2 = parsedValues[1];
          value3 = parsedValues[2];
        }

        // Store the raw received message if needed
        receivedMessage = message;
      }
    } catch (e) {
      debugPrint('Error processing received data: $e');
    }
  }

  /// Process backspace characters in the received data and handle the message format "12,12,12".
  Uint8List _processBackspaces(Uint8List data) {
    int backspacesCounter = 0;

    // Count backspace characters
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }

    // Create buffer for cleaned data
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Convert cleaned Uint8List to string, split numbers, and remove spaces
    String cleanedString = String.fromCharCodes(buffer);
    cleanedString = cleanedString.replaceAll(' ', ''); // Remove spaces
    List<String> separatedNumbers = cleanedString.split(','); // Split by commas

    // Convert the processed string back to Uint8List
    return Uint8List.fromList(cleanedString.codeUnits);
  }


  /// Dispose of the Bluetooth connection
  void dispose() {
    if (connection != null && isConnected) {
      isDisconnecting = true;
      connection!.dispose();
      debugPrint('Connection disposed.');
    }
  }
}
