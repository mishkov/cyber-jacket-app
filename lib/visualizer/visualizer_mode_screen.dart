import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../connection_provider.dart';
import 'spectrometer.dart';

class VisualizerModeScreen extends StatefulWidget {
  static const route = '/visualizer';

  const VisualizerModeScreen({Key? key}) : super(key: key);

  @override
  State<VisualizerModeScreen> createState() => _VisualizerModeScreenState();
}

class _VisualizerModeScreenState extends State<VisualizerModeScreen> {
  final _soundFrequencyMeter = Spectrometer();
  Timer? frameUpdater;

  Float64List _data = Float64List(0);
  final _lastData = List<num>.filled(8, 0.0);

  Uint8List _lastFrame = Uint8List(8);

  @override
  void initState() {
    super.initState();
    final connectionProvider = context.read<BluetoothConnectionCubit>();

    frameUpdater = Timer.periodic(
      const Duration(milliseconds: 40),
      (_) {
        connectionProvider.sendByteFrame(_lastFrame);
      },
    );
    intFrequencyListener();
  }

  @override
  void dispose() {
    frameUpdater?.cancel();
    super.dispose();
  }

  void intFrequencyListener() {
    _soundFrequencyMeter.addFrequencyListener(
      (data) {
        if (data == null) return;
        if (!mounted) return;

        setState(() {
          _data = data;
        });
      },
      () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: DataPainter(
              _data,
              _lastData,
              (frame) {
                _lastFrame = frame;
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DataPainter extends CustomPainter {
  List<num> data;
  List<num> lastData;

  void Function(Uint8List frame) onFrame;

  DataPainter(
    this.data,
    this.lastData,
    this.onFrame,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    _drawData(data, size, canvas);
  }

  void _drawData(Iterable<num> data, Size size, Canvas canvas) {
    final columnWidth = size.width / data.length;
    final maxColumnHeight = size.height;

    const maxValue = 8;

    for (int i = 0; i < data.length; i++) {
      num value;
      if (data.elementAt(i) > lastData.elementAt(i)) {
        value = data.elementAt(i);
      } else {
        value = math.max(lastData.elementAt(i) - 0.5, 0);
      }

      lastData[i] = value.toDouble();

      // draw on screen
      final columnHeigt = (value / maxValue) * maxColumnHeight;

      final columnPaint = Paint()..color = Colors.blue;

      final left = i * columnWidth;
      final top = maxColumnHeight - columnHeigt;
      final column = Rect.fromLTWH(left, top, columnWidth, columnHeigt);

      canvas.drawRect(column, columnPaint);
    }

    Uint8List frame = Uint8List(8);

    for (int i = 0; i < frame.length; i++) {
      int row = 0;

      for (int j = 0; j < lastData.length; j++) {
        if (lastData[j] >= (8 - i)) {
          row |= 1 << (7 - j);
        }
      }
      frame[i] = row;
    }

    onFrame(frame);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
