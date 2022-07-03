import 'dart:typed_data';

import 'package:cyber_jacket/database.dart';
import 'package:cyber_jacket/template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connection_provider.dart';

class DrawModeScreen extends StatefulWidget {
  static const route = '/draw';
  const DrawModeScreen({Key? key}) : super(key: key);

  @override
  State<DrawModeScreen> createState() => _DrawModeScreenState();
}

class _DrawModeScreenState extends State<DrawModeScreen> {
  List<List<bool>> matrix =
      List.generate(8, (_) => List.generate(8, (_) => false));
  MatrixDrawMode _matrixDrawMode = MatrixDrawMode.draw;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: BlocBuilder<BluetoothConnectionCubit, BluetoothConnectionState>(
            builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                LedMatrix(matrix: matrix, mode: _matrixDrawMode),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _matrixDrawMode = MatrixDrawMode.draw;
                        });
                      },
                      icon: const Icon(Icons.circle),
                      label: const Text('Draw'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _matrixDrawMode = MatrixDrawMode.erase;
                        });
                      },
                      icon: const Icon(Icons.circle_outlined),
                      label: const Text('Erase'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          matrix = List.generate(
                              8, (_) => List.generate(8, (_) => false));
                          final connectionProvider =
                              context.read<BluetoothConnectionCubit>();
                          connectionProvider.sendFrame(matrix);
                        });
                      },
                      icon: const Icon(Icons.highlight_remove),
                      label: const Text('Clear'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          matrix = List.generate(
                              8, (_) => List.generate(8, (_) => true));
                          final connectionProvider =
                              context.read<BluetoothConnectionCubit>();
                          connectionProvider.sendFrame(matrix);
                        });
                      },
                      icon: const Icon(Icons.rectangle_rounded),
                      label: const Text('Fill'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              final nameController = TextEditingController();
                              return Dialog(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Save To Templates',
                                        style: TextStyle(
                                          fontSize: 24,
                                        ),
                                      ),
                                      TextFormField(
                                        controller: nameController,
                                      ),
                                      const SizedBox(height: 50),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final bytes = List<int>.generate(
                                                  8, (index) {
                                                final row = matrix[index];
                                                var rowByte = 0;
                                                for (int i = 0; i < 8; i++) {
                                                  if (row[i] == true) {
                                                    final bitsToShift = 7 - i;
                                                    final currentBit =
                                                        1 << bitsToShift;
                                                    final newRow =
                                                        rowByte | currentBit;
                                                    rowByte = newRow;
                                                  }
                                                }
                                                return rowByte;
                                              });
                                              final template = Template(
                                                nameController.text,
                                                Uint8List.fromList(bytes),
                                              );

                                              await Database.instance
                                                  .insertTemplate(template);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save...'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

enum MatrixDrawMode { draw, erase }

class LedMatrix extends StatefulWidget {
  const LedMatrix({
    Key? key,
    required this.mode,
    required this.matrix,
  }) : super(key: key);

  final List<List<bool>> matrix;
  final MatrixDrawMode mode;

  @override
  State<LedMatrix> createState() => _LedMatrixState();
}

class _LedMatrixState extends State<LedMatrix> {
  void processTap(Offset cursorPosition) {
    final matrixSize = (context.findRenderObject() as RenderBox).size;
    if (cursorPosition.dx.isNegative || cursorPosition.dx >= matrixSize.width) {
      return;
    }
    if (cursorPosition.dy.isNegative ||
        cursorPosition.dy >= matrixSize.height) {
      return;
    }
    final pixelByX = (cursorPosition.dx * 8) ~/ matrixSize.width;
    final pixelByY = (cursorPosition.dy * 8) ~/ matrixSize.height;
    setState(() {
      if (widget.mode == MatrixDrawMode.draw) {
        widget.matrix[pixelByY][pixelByX] = true;
      } else {
        widget.matrix[pixelByY][pixelByX] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) {
        processTap(details.localPosition);
      },
      onPanEnd: (_) {
        final connectionProvider = context.read<BluetoothConnectionCubit>();
        connectionProvider.sendFrame(widget.matrix);
      },
      onPanUpdate: (details) {
        processTap(details.localPosition);
      },
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 8,
        children: List.generate(64, (index) {
          final row = index % 8;
          final column = index ~/ 8;
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: widget.matrix[column][row] ? Colors.red : Colors.grey,
            ),
          );
        }),
      ),
    );
  }
}
