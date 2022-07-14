import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class AvailableDevice extends StatelessWidget {
  const AvailableDevice({
    Key? key,
    required this.device,
    this.onConnect,
  }) : super(key: key);

  final BluetoothDevice device;
  final void Function()? onConnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(device.name ?? device.address),
        subtitle: Text(device.name != null ? device.address : ''),
        trailing: TextButton(
          onPressed: device.isConnected ? null : onConnect,
          child: Text(device.isConnected ? 'Connected' : 'Connect'),
        ),
      ),
    );
  }
}
