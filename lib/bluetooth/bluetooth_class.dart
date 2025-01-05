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
  String receivedMessage = 'test';

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
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

    int index = buffer.indexOf(13);
    if (~index != 0) {
    } else {}
  }

  void connectToDevice(BluetoothDevice device) async {
    if (device == connectedDevice) {
      return;
    }
    connectedDevice = device;
    serverName = device.name ?? "Unknown";

    BluetoothConnection.toAddress(device.address).then((connection) {
      debugPrint('Connected to the device');
      this.connection = connection;
      isConnecting = false;
      isDisconnecting = false;

      connection.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          debugPrint('Disconnecting locally!');
          isConnecting = true;
        } else {
          debugPrint('Disconnected remotely!');
          isConnecting = true;
        }
      });
    }).catchError((error) {
      debugPrint('Cannot connect, exception occured');
      isConnecting = true;
      debugPrint(error);
    });
  }

  void sendBlMessage(String message) async {
    if (connection == null) {
      debugPrint('No connection established');
      return;
    }
    final text = message.trim();

    if (text.isNotEmpty) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode("$text\r\n")));
        await connection!.output.allSent;

        debugPrint('Sent: $text');
      } catch (e) {
        debugPrint('Error: $e');
        rethrow;
      }
    }
  }

  void receiveBlMessage() {
    if (connection == null) {
      debugPrint('No connection established');
      return;
    }

    connection!.input?.listen((Uint8List data) {
      try {
        receivedMessage = 'test';
        // Process the raw data to handle backspaces
        final cleanedData = _processBackspaces(data);

        // Convert to a readable string
        final message = String.fromCharCodes(cleanedData).trim();

        if (message.isNotEmpty) {
          debugPrint('Received: $message');
          receivedMessage = message;

        }
      } catch (e) {
        receivedMessage = 'Error while processing received data: $e';
      }
    }).onError((error) {
      receivedMessage = 'Error receiving data: $error';
    });
  }

// Function to process backspace characters in the received data
  Uint8List _processBackspaces(Uint8List data) {
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }

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

    return buffer;
  }
}
