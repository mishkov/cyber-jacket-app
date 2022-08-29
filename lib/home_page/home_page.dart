import 'package:cyber_jacket/draw/draw_mode_screen.dart';
import 'package:cyber_jacket/home_page/connection_dashboard.dart';
import 'package:cyber_jacket/home_page/status_bar.dart';
import 'package:cyber_jacket/pulse/pulse_mode_screen.dart';
import 'package:cyber_jacket/visualizer/visualizer_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cyber_jacket/connection_provider.dart';
import 'package:cyber_jacket/running_text/running_text_mode_screen.dart';
import 'package:cyber_jacket/templates/templates_screen.dart';

class MyHomePage extends StatefulWidget {
  static const route = '/';
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cyber Jacket'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: StatusBar(),
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
                  const ConnectionDashboard(),
                  const Spacer(),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed:
                            state.status == BluetoothConnectionStatus.connected
                                ? () {
                                    Navigator.pushNamed(
                                      context,
                                      RunningTextModeScreen.route,
                                    );
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
                                      context,
                                      TemplatesScreen.route,
                                    );
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
                                      context,
                                      PulseModeScreen.route,
                                    );
                                  }
                                : null,
                        child: const Text('Pulse'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed:
                            state.status == BluetoothConnectionStatus.connected
                                ? () {
                                    Navigator.pushNamed(
                                      context,
                                      VisualizerModeScreen.route,
                                    );
                                  }
                                : null,
                        child: const Text('Visualizer'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed:
                            state.status == BluetoothConnectionStatus.connected
                                ? () {
                                    Navigator.pushNamed(
                                      context,
                                      DrawModeScreen.route,
                                    );
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
