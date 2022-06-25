import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

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
  final _bluetooth = FlutterBluetoothSerial.instance;
  final _devices = <BluetoothDevice>[];
  final _controller = ScrollController();
  String _bluetoothConnectionStatus = 'No bluetooth connection';
  BluetoothConnection? _connection;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        _bluetoothConnectionStatus =
            'Connected to ${device.name ?? device.address}';
      });

      _connection!.input?.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
        _connection!.output.add(data); // Sending data

        if (ascii.decode(data).contains('!')) {
          _connection!.finish();
          setState(() {
            _bluetoothConnectionStatus = 'Bluetooth connection is finished';
          });
        }
      }).onDone(() {
        setState(() {
          _bluetoothConnectionStatus = 'Bluetooth connection is done';
        });
      });
    } catch (exception) {
      setState(() {
        _bluetoothConnectionStatus = 'Cannot connect, exception occured';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cyber Jacket'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _bluetoothConnectionStatus,
                style: const TextStyle(
                  color: Colors.white,
                ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _connection == null
                        ? null
                        : () async {
                            await _connection?.finish();
                            _connection?.dispose();
                          },
                    child: const Text('Disconnect'),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _devices.clear();
                      });
                      if (!(await _bluetooth.isEnabled ?? false)) {
                        await _bluetooth.requestEnable();
                      }
                      final scaning = _bluetooth.startDiscovery();
                      scaning.listen((event) {
                        setState(() {
                          _devices.add(event.device);
                          if (_controller.hasClients) {
                            // TODO: Check behavior of this code
                            _controller
                                .jumpTo(_controller.position.maxScrollExtent);
                          }
                        });
                      }, onError: (error, stackTrace) {
                        log('$error -> $stackTrace');
                      }, onDone: () {
                        log('scanning stream is done');
                      });
                    },
                    child: const Text('Scan'),
                  ),
                ],
              ),
              Expanded(
                child: _devices.isNotEmpty
                    ? ListView.builder(
                        controller: _controller,
                        shrinkWrap: true,
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          final device = _devices[index];
                          return AvailableDevice(
                            device: device,
                            onConnect: () {
                              _connectToDevice(device);
                            },
                          );
                        },
                      )
                    : const Text('No devices detected'),
              ),
            ],
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
