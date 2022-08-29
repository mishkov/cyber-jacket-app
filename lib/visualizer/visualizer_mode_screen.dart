import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../connection_provider.dart';
import 'config_screen.dart';
import 'visualizer.dart';
import 'visualizer_configuration.dart';
import 'visualzier_view.dart';

class VisualizerModeScreen extends StatefulWidget {
  static const route = '/visualizer';

  const VisualizerModeScreen({Key? key}) : super(key: key);

  @override
  State<VisualizerModeScreen> createState() => _VisualizerModeScreenState();
}

class _VisualizerModeScreenState extends State<VisualizerModeScreen> {
  final _visualizer = Visualizer();
  MatrixVisualizer? _matrixVisualizer;

  Float64List _data = Float64List(8);
  VisualizerConfiguration? _currentConfig;

  @override
  void initState() {
    super.initState();

    _visualizer.getConfig().then((config) {
      _currentConfig = config;
    });

    final bluetooth = context.read<BluetoothConnectionCubit>();
    _matrixVisualizer = MatrixVisualizer(bluetooth: bluetooth);

    initColumnsListener();
  }

  @override
  void dispose() {
    _matrixVisualizer?.stop();
    super.dispose();
  }

  void initColumnsListener() {
    _visualizer.addListener((data) {
      if (data == null) return;
      if (!mounted) return;

      setState(() {
        _data = data;
        _matrixVisualizer?.addColumns(_data);
      });
    }, showRecordPermissionDeniedMessage);
  }

  void showRecordPermissionDeniedMessage() {
    final messenger = ScaffoldMessenger.of(context);

    const message = SnackBar(
      content: Text('Permission Denied. Cannot record audio.'),
    );
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizer'),
        actions: [
          IconButton(
            onPressed: () async {
              final config = await Navigator.pushNamed<VisualizerConfiguration>(
                context,
                ConfigScreen.route,
                arguments: _currentConfig,
              );

              if (config != null) {
                _currentConfig = config;
                _visualizer.setConfig(config);
              }
            },
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: VisualizerView(
            columns: _data,
            maxHeight: Visualizer.maxColumnHeight,
          ),
        ),
      ),
    );
  }
}

class MatrixVisualizer {
  static const _columnsCount = 8;

  Timer? _frameUpdater;

  final List<num> _oldColumns = List.filled(_columnsCount, 0);
  List<num> _columns = List.filled(_columnsCount, 0);

  BluetoothConnectionCubit bluetooth;

  MatrixVisualizer({required this.bluetooth}) {
    _frameUpdater =
        Timer.periodic(const Duration(milliseconds: 70), _updateFrame);
  }

  void stop() {
    _frameUpdater?.cancel();
  }

  void addColumns(List<num> columns) {
    if (columns.length != _columnsCount) {
      throw Exception('Incorrect columns length');
    }

    _columns = columns;
  }

  void _updateFrame(Timer timer) {
    for (var i = 0; i < _columns.length; i++) {
      num value;
      if (_columns[i] > _oldColumns[i]) {
        value = _columns[i];
      } else {
        const maxValue = Visualizer.maxColumnHeight;
        const downStep = maxValue / 40;

        value = math.max(_oldColumns[i] - downStep, 0);
      }

      _oldColumns[i] = value.toDouble();
    }

    final frame = Uint8List(_columnsCount);

    for (var i = 0; i < frame.length; i++) {
      var row = 0;

      for (var j = 0; j < _oldColumns.length; j++) {
        if (_oldColumns[j].round() >= (_columnsCount - i)) {
          row |= 1 << ((_columnsCount - 1) - j);
        }
      }
      frame[i] = row;
    }

    bluetooth.sendByteFrame(frame);
  }
}
