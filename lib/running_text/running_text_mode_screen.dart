import 'dart:async';

import 'package:cyber_jacket/running_text/chars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../connection_provider.dart';

class RunningTextModeScreen extends StatefulWidget {
  static const route = '/running-text';

  const RunningTextModeScreen({Key? key}) : super(key: key);

  @override
  State<RunningTextModeScreen> createState() => _RunningTextModeScreenState();
}

class _RunningTextModeScreenState extends State<RunningTextModeScreen> {
  final _textController = TextEditingController();
  Timer? frameUpdater;
  List<int> columns = [];
  int index = 0;

  @override
  void dispose() {
    frameUpdater?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionProvider = context.read<BluetoothConnectionCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Text'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _textController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text = '';
                    });
                    frameUpdater?.cancel();
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    columns = stringToColumnsBytes("${_textController.text} ");
                    index = 0;
                    frameUpdater?.cancel();
                    frameUpdater = Timer.periodic(
                      const Duration(milliseconds: 100),
                      (_) {
                        if (index >= columns.length) {
                          index = 0;
                        }
                        connectionProvider
                            .sendByteFrame(extractFrame(columns, index));
                        index++;
                      },
                    );
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
