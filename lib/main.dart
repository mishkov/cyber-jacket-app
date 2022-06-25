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
  Stream<BluetoothState>? _bluetoothStateStream;

  @override
  void initState() {
    super.initState();
    _bluetoothStateStream = _bluetooth.onStateChanged();
  }

  Future<void> _connectToDevice(String address) async {
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(address);
      setState(() {
        print('Connected to the device');
      });

      connection.input?.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
        connection.output.add(data); // Sending data

        if (ascii.decode(data).contains('!')) {
          connection.finish();
          setState(() {}); // Closing connection
          print('Disconnecting by local host');
        }
      }).onDone(() {
        setState(() {});
        print('Disconnected by remote request');
      });
    } catch (exception) {
      setState(() {});
      print('Cannot connect, exception occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    const statusTextStyle = TextStyle(
      color: Colors.white,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cyber Jacket'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<BluetoothState>(
                  stream: _bluetoothStateStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!.stringValue,
                        style: statusTextStyle,
                      );
                    } else {
                      return const Text(
                        'Unknown bluetooth state',
                        style: statusTextStyle,
                      );
                    }
                  },
                ),
              ],
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
                              _connectToDevice(device.address);
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
