import 'package:cyber_jacket/database.dart' as localdb;
import 'package:cyber_jacket/draw_mode_screen.dart';
import 'package:cyber_jacket/connection_provider.dart';
import 'package:cyber_jacket/running_text_mode_screen.dart';
import 'package:cyber_jacket/templates_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'sliver_list_with_contoller_layout.dart';

Future<void> main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  localdb.Database.instance.init();
  runApp(
    BlocProvider(
      create: (context) => BluetoothConnectionCubit(),
      child: const MyApp(),
    ),
  );
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
            if (routeSettings.name == DrawModeScreen.route) {
              return const DrawModeScreen();
            } else if (routeSettings.name == TemplatesScreen.route) {
              return const TemplatesScreen();
            } else if (routeSettings.name == RunningTextModeScreen.route) {
              return const RunningTextModeScreen();
            } else {
              return const MyHomePage();
            }
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.topCenter,
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
                        onPressed: () {
                          connectionProvider.scan();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: ScanningDialog(),
                              );
                            },
                          );
                          connectionProvider.stopScan();
                        },
                        child: const Text('Scan'),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed:
                            state.status == BluetoothConnectionStatus.connected
                                ? () {
                                    Navigator.pushNamed(
                                        context, RunningTextModeScreen.route);
                                  }
                                : null,
                        child: const Text('Running Text'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed:
                            state.status == BluetoothConnectionStatus.connected
                                ? () {
                                    Navigator.pushNamed(
                                        context, TemplatesScreen.route);
                                  }
                                : null,
                        child: const Text('Templates'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed:
                            state.status == BluetoothConnectionStatus.connected
                                ? () {
                                    Navigator.pushNamed(
                                        context, DrawModeScreen.route);
                                  }
                                : null,
                        child: const Text('Draw'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ScanningDialog extends StatelessWidget {
  ScanningDialog({
    Key? key,
  }) : super(key: key);

  final availableDevicesListScrollController = ScrollController();
  final updateLayoutController = UpdateLayoutController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<BluetoothConnectionCubit, BluetoothConnectionState>(
            builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  state.isScanning ? 'Scanning...' : 'Found Devices',
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
              state.devices.isNotEmpty
                  ? BlocListener<BluetoothConnectionCubit,
                      BluetoothConnectionState>(
                      listenWhen: (previous, current) {
                        return previous.devices.length !=
                            current.devices.length;
                      },
                      listener: (context, state) {
                        if (availableDevicesListScrollController.hasClients) {
                          updateLayoutController.layoutUpdater?.call();
                          availableDevicesListScrollController.animateTo(
                            availableDevicesListScrollController
                                .position.maxScrollExtent,
                            duration: const Duration(seconds: 1),
                            curve: Curves.ease,
                          );
                        }
                      },
                      child: BlocBuilder<BluetoothConnectionCubit,
                          BluetoothConnectionState>(
                        builder: (context, state) {
                          return CustomScrollView(
                            controller: availableDevicesListScrollController,
                            shrinkWrap: true,
                            slivers: [
                              SliverListWithControlledLayout(
                                updateLayoutController: updateLayoutController,
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final device = state.devices[index];
                                    return AvailableDevice(
                                      device: device,
                                      onConnect: () {
                                        final connectionProvider = context
                                            .read<BluetoothConnectionCubit>();
                                        connectionProvider.connectTo(device);
                                      },
                                    );
                                  },
                                  childCount: state.devices.length,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : const Text('No devices detected'),
            ],
          );
        }),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('cancel'),
            ),
          ),
        )
      ],
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
          onPressed: device.isConnected ? null : onConnect,
          child: Text(device.isConnected ? 'Connected' : 'Connect'),
        ),
      ),
    );
  }
}
