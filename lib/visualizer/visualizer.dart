import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'visualizer_configuration.dart';

/// Receives 8 columns of frequency range.
///
/// Each columns is in range [0, 8].
typedef ColumnsListener = void Function(Float64List? columns);

class Visualizer {
  final _controllerChannel = const MethodChannel('visualizer_controller');
  final _eventChannel = const EventChannel('visualizer');

  final _futureIsMicrophonePermissionGranted =
      Permission.microphone.request().then((permissionStatus) {
    return permissionStatus.isGranted;
  });

  Future<void> setConfig(VisualizerConfiguration config) async {
    _controllerChannel.invokeMethod(
      "updateConfig",
      config.toMap(),
    );
  }

  Future<VisualizerConfiguration?> getConfig() async {
    final mapConfig = await _controllerChannel.invokeMapMethod<String, dynamic>(
      'getConfig',
    );
    if (mapConfig == null) {
      return null;
    } else {
      return VisualizerConfiguration.fromMap(mapConfig);
    }
  }

  Future<void> addListener(
    ColumnsListener listener,
    VoidCallback onPermissionDenied,
  ) async {
    final canRecord = await _futureIsMicrophonePermissionGranted;

    if (!canRecord) {
      onPermissionDenied();
      return;
    }

    void safeListener(event) {
      if (event is Float64List?) {
        listener(event);
      }
    }

    _eventChannel.receiveBroadcastStream().listen(safeListener);
  }
}
