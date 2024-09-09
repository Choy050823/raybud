import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BluetoothConnection? connection;
  BluetoothDevice? _selectedDevice;
  String _receivedMessage = "No message received";
  bool isConnecting = false;
  bool isConnected = false;
  List<BluetoothDevice> _devicesList = [];

  @override
  void initState() {
    super.initState();
    _autoConnectDevice();
  }

  Future<void> _requestBluetoothPermissions() async {
    if (await Permission.bluetooth.isGranted &&
        await Permission.bluetoothConnect.isGranted) {
      // Permissions are already granted
      return;
    }

    // Request permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();

    if (statuses[Permission.bluetoothConnect] != PermissionStatus.granted) {
      // Handle permission not granted case
      print("Bluetooth connect permission not granted");
    }
  }

  // Automatically connect to the saved device
  Future<void> _autoConnectDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAddress = prefs.getString('savedDeviceAddress');

    if (savedAddress != null) {
      await _requestBluetoothPermissions();
      BluetoothDevice? device = await _getDeviceByAddress(savedAddress);
      if (device != null) {
        _selectedDevice = device;
        _connectDevice();
      }
    }
  }

  // Discover nearby Bluetooth devices
  Future<void> _discoverDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      await _requestBluetoothPermissions();
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      print('Error discovering devices: $e');
    }

    setState(() {
      _devicesList = devices;
      print(_devicesList);
    });

    _showDeviceSelectionDialog();
  }

  // Show dialog for selecting a Bluetooth device
  Future<void> _showDeviceSelectionDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Bluetooth Device'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_devicesList[index].name ?? "Unknown Device"),
                  subtitle: Text(_devicesList[index].address),
                  onTap: () async {
                    // Save selected device and connect
                    _selectedDevice = _devicesList[index];
                    await _saveDeviceToPrefs(_selectedDevice!);
                    _connectDevice();
                    Navigator.of(context).pop(); // Close dialog
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Save selected device address to SharedPreferences
  Future<void> _saveDeviceToPrefs(BluetoothDevice device) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedDeviceAddress', device.address);
  }

  // Get BluetoothDevice by MAC address
  Future<BluetoothDevice?> _getDeviceByAddress(String address) async {
    List<BluetoothDevice> devices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    try {
      return devices.firstWhere((device) => device.address == address);
    } catch (e) {
      return null;
    }
  }

  // Connect to the selected Bluetooth device
  Future<void> _connectDevice() async {
    if (_selectedDevice != null) {
      setState(() {
        isConnecting = true;
      });

      try {
        connection =
            await BluetoothConnection.toAddress(_selectedDevice!.address);
        setState(() {
          isConnected = true;
          isConnecting = false;
        });
        print('Connected to ${_selectedDevice!.name}');

        // Listen for incoming data from ESP32
        connection!.input!.listen((data) {
          setState(() {
            _receivedMessage = String.fromCharCodes(data).trim();
          });
          print("Message from ESP32: $_receivedMessage");
        }).onDone(() {
          setState(() {
            isConnected = false;
          });
          print('Disconnected by ESP32');
        });
      } catch (e) {
        print('Connection error: $e');
        setState(() {
          isConnecting = false;
          isConnected = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32 Bluetooth Auto Connect'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_selectedDevice != null)
              Text(
                  "Device: ${_selectedDevice!.name}, Address: ${_selectedDevice!.address}")
            else
              const Text("No device found"),
            const SizedBox(height: 20),
            // ElevatedButton(
            // onPressed: isConnecting
            //     ? null
            //     : _discoverDevices, // Disable button if connecting
            //   child:
            //       Text(isConnected ? "Connected" : "Select and Connect Device"),
            // ),
            Center(
              child: Container(
                width: 200.0, // Set the width of the button
                height:
                    200.0, // Set the height of the button (same as width to make it circular)
                decoration: const BoxDecoration(
                  color: Colors.blue, // Background color of the button
                  shape: BoxShape.circle, // Makes the button circular
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape:
                        const CircleBorder(), // Ensures the button stays circular
                    padding: const EdgeInsets.all(40), // Text color
                  ),
                  onPressed: isConnecting ? null : _discoverDevices,
                  child: Text(
                    isConnected ? "Connected" : "Select and Connect Device",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Latest Message from ESP32:"),
            Text(
              _receivedMessage,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (!isConnected && !isConnecting)
              const Text("Disconnected. Reconnect to get new messages.")
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(context, '/exercise');
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    if (connection != null && connection!.isConnected) {
      connection!.dispose(); // Dispose of connection when leaving the page
    }
    super.dispose();
  }
}
