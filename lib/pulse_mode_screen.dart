import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'chars.dart';
import 'connection_provider.dart';

class PulseModeScreen extends StatefulWidget {
  static const route = '/pulse';

  const PulseModeScreen({Key? key}) : super(key: key);

  @override
  State<PulseModeScreen> createState() => _PulseModeScreenState();
}

class _PulseModeScreenState extends State<PulseModeScreen> {
  Timer? frameUpdater;
  List<int> columns = [];
  int index = 0;

  @override
  void initState() {
    super.initState();

    final connectionProvider = context.read<BluetoothConnectionCubit>();

    columns = [
      2,
      4,
      2,
      28,
      224,
      28,
      3,
      4,
      ...List.filled(8, 2),
    ];
    frameUpdater = Timer.periodic(
      const Duration(milliseconds: 70),
      (_) {
        if (index >= columns.length) {
          index = 0;
        }
        connectionProvider.sendByteFrame(extractFrame(columns, index));
        index++;
      },
    );
  }

  @override
  void dispose() {
    frameUpdater?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8),
        child: Text('Pulse is displayed on Cyber Jacket'),
      ),
    );
  }
}
