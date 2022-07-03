import 'package:cyber_jacket/chat_screen.dart';
import 'package:cyber_jacket/connection_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber Jacket',
      initialRoute: MyHomePage.route,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) {
            return BlocProvider(
              create: (context) => BluetoothConnectionCubit(),
              child: Builder(
                builder: (context) {
                  if (routeSettings.name == ChatScreen.route) {
                    return const ChatScreen();
                  } else {
                    return const MyHomePage();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const route = '/';
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final connectionProvider = context.read<BluetoothConnectionCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cyber Jacket'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<BluetoothConnectionCubit,
                  BluetoothConnectionState>(
                builder: (context, state) {
                  String message;
                  if (state.status == BluetoothConnectionStatus.unknown) {
                    message = 'Unknown connection state';
                  } else if (state.status ==
                      BluetoothConnectionStatus.connected) {
                    message =
                        'Connected to ${state.connectedDevice!.name ?? state.connectedDevice!.address}';
                  } else if (state.status == BluetoothConnectionStatus.done) {
                    message = 'Connection is done';
                  } else if (state.status ==
                      BluetoothConnectionStatus.finished) {
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
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, ChatScreen.route);
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.topCenter,
          child:
              BlocListener<BluetoothConnectionCubit, BluetoothConnectionState>(
            listenWhen: (previous, current) {
              return previous.devices.length != current.devices.length;
            },
            listener: (context, state) {
              if (_controller.hasClients) {
                setState(() {
                  _controller.jumpTo(_controller.position.maxScrollExtent);
                });
              }
            },
            child:
                BlocBuilder<BluetoothConnectionCubit, BluetoothConnectionState>(
                    builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: state.connectedDevice != null
                            ? connectionProvider.disconnect
                            : null,
                        child: const Text('Disconnect'),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                        onPressed:
                            !state.isScanning ? connectionProvider.scan : null,
                        child: const Text('Scan'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: state.devices.isNotEmpty
                        ? ListView.builder(
                            controller: _controller,
                            shrinkWrap: true,
                            itemCount: state.devices.length,
                            itemBuilder: (context, index) {
                              final device = state.devices[index];
                              return AvailableDevice(
                                device: device,
                                onConnect: () {
                                  connectionProvider.connectTo(device);
                                },
                              );
                            },
                          )
                        : const Text('No devices detected'),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

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
          onPressed: onConnect,
          child: Text(device.isConnected ? 'Connected' : 'Connect'),
        ),
      ),
    );
  }
}
