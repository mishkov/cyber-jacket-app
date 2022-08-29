import 'dart:math' as math;

import 'package:cyber_jacket/visualizer/visualizer_configuration.dart';
import 'package:flutter/material.dart';

class ConfigScreen extends StatefulWidget {
  static const route = '/visualizer_config';

  const ConfigScreen({Key? key, this.configuration}) : super(key: key);

  final VisualizerConfiguration? configuration;

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _maxAmplitude = 100000.0;
  double _amplitudeThreshold = 10000;
  double _amplitudeLimit = 30000;

  @override
  void initState() {
    super.initState();

    _amplitudeThreshold =
        widget.configuration?.amplitudeThreshold ?? _amplitudeThreshold;
    _amplitudeLimit = widget.configuration?.amplitudeLimit ?? _amplitudeLimit;
  }

  @override
  Widget build(BuildContext context) {
    const sliderTheme = SliderThemeData(
      showValueIndicator: ShowValueIndicator.always,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 48,
          bottom: 24,
          left: 8,
          right: 8,
        ),
        child: SliderTheme(
          data: sliderTheme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                label: _amplitudeThreshold.toStringAsFixed(2),
                min: 0,
                max: _maxAmplitude,
                value: _amplitudeThreshold,
                onChanged: (value) {
                  setState(() {
                    _amplitudeThreshold = value;
                    _amplitudeLimit =
                        math.max(_amplitudeLimit, _amplitudeThreshold);
                  });
                },
              ),
              const SizedBox(height: 24),
              Slider(
                label: _amplitudeLimit.toStringAsFixed(2),
                min: 1000,
                max: _maxAmplitude,
                value: _amplitudeLimit,
                onChanged: (value) {
                  if (value >= _amplitudeThreshold) {
                    setState(() {
                      _amplitudeLimit = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Configuration',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Amplitude Threshold:"),
                  const SizedBox(
                    width: 16,
                  ),
                  Text(_amplitudeThreshold.toStringAsFixed(2))
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("Amplitude Limit:"),
                  const SizedBox(
                    width: 16,
                  ),
                  Text(_amplitudeLimit.toStringAsFixed(2))
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        VisualizerConfiguration(
                          amplitudeThreshold: _amplitudeThreshold,
                          amplitudeLimit: _amplitudeLimit,
                        ),
                      );
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
