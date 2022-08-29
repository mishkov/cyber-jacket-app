import 'package:cyber_jacket/templates/database.dart' as localdb;
import 'package:cyber_jacket/draw/draw_mode_screen.dart';
import 'package:cyber_jacket/connection_provider.dart';
import 'package:cyber_jacket/pulse/pulse_mode_screen.dart';
import 'package:cyber_jacket/running_text/running_text_mode_screen.dart';
import 'package:cyber_jacket/templates/templates_screen.dart';
import 'package:cyber_jacket/visualizer/visualizer_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_page/home_page.dart';

Future<void> main() async {
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
            } else if (routeSettings.name == PulseModeScreen.route) {
              return const PulseModeScreen();
            } else if (routeSettings.name == VisualizerModeScreen.route) {
              return const VisualizerModeScreen();
            } else {
              return const MyHomePage();
            }
          },
        );
      },
    );
  }
}
