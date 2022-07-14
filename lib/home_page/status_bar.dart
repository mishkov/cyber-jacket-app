import 'package:cyber_jacket/connection_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<BluetoothConnectionCubit, BluetoothConnectionState>(
          builder: (context, state) {
            String message;
            if (state.status == BluetoothConnectionStatus.unknown) {
              message = 'Unknown connection state';
            } else if (state.status == BluetoothConnectionStatus.connected) {
              message =
                  'Connected to ${state.connectedDevice!.name ?? state.connectedDevice!.address}';
            } else if (state.status == BluetoothConnectionStatus.done) {
              message = 'Connection is done';
            } else if (state.status == BluetoothConnectionStatus.finished) {
              message = 'Connection is finished';
            } else if (state.status == BluetoothConnectionStatus.error) {
              message = 'Error occured';
            } else {
              message = 'Undefined connection state';
            }

            return Text(
              message,
              style: const TextStyle(
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
