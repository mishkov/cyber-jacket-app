import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class Spectrometer {
  final _frequencyChannel = const EventChannel('visualizer');

  final _futureIsMicrophonePermissionGranted =
      Permission.microphone.request().then(
    (permissionStatus) {
      return permissionStatus.isGranted;
    },
  );

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
