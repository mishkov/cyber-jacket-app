import 'dart:typed_data';

import 'package:cyber_jacket/visualizer/visualizer_configuration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class Spectrometer {
  final _methodChannel = const MethodChannel('visualizer_controller');
  final _frequencyChannel = const EventChannel('visualizer');

  final _futureIsMicrophonePermissionGranted =
      Permission.microphone.request().then(
    (permissionStatus) {
      return permissionStatus.isGranted;
    },
  );

  Future<void> setConfig(VisualizerConfiguration config) async {
    _methodChannel.invokeMethod(
      "updateConfig",
      config.toMap(),
    );
  }

  Future<VisualizerConfiguration?> getConfig() async {
    final mapConfig = await _methodChannel.invokeMapMethod<String, dynamic>(
      'getConfig',
    );
    if (mapConfig == null) {
      return null;
    } else {
      return VisualizerConfiguration.fromMap(mapConfig);
    }
  }

  void addFrequencyListener(void Function(Float64List? data) listener,
      VoidCallback onPermissionDenied) async {
    _futureIsMicrophonePermissionGranted.then((isGranted) {
      if (isGranted) {
        void safeListener(event) {
          if (event is Float64List?) {
            listener(event);
          }
        }

        _frequencyChannel.receiveBroadcastStream().listen(safeListener);
      }
    });
  }
}
