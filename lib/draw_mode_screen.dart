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
