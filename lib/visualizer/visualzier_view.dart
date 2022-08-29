import 'dart:math' as math;

import 'package:flutter/material.dart';

class VisualizerView extends StatefulWidget {
  const VisualizerView(
      {Key? key, required this.columns, required this.maxHeight})
      : super(key: key);

  final List<num> columns;
  final double maxHeight;

  @override
  State<VisualizerView> createState() => _VisualizerViewState();
}

class _VisualizerViewState extends State<VisualizerView> {
  List<num> _oldColumns = List.filled(8, 0);

  @override
  void initState() {
    super.initState();

    _oldColumns = widget.columns;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ColumnsPainter(
        widget.columns,
        _oldColumns,
        widget.maxHeight,
      ),
    );
  }
}

class ColumnsPainter extends CustomPainter {
  final List<num> columns;
  final List<num> oldColumns;
  final double maxHeight;

  ColumnsPainter(this.columns, this.oldColumns, this.maxHeight);

  @override
  void paint(Canvas canvas, Size size) {
    if (columns.isEmpty) return;

    _drawData(size, canvas);
  }

  void _drawData(Size size, Canvas canvas) {
    final columnWidth = size.width / columns.length;
    final maxColumnHeight = size.height;

    final maxValue = maxHeight;

    for (int i = 0; i < columns.length; i++) {
      num value;
      if (columns.elementAt(i) > oldColumns.elementAt(i)) {
        value = columns.elementAt(i);
      } else {
        final downStep = maxValue / 40;
        value = math.max(oldColumns.elementAt(i) - downStep, 0);
      }

      oldColumns[i] = value.toDouble();

      final columnHeigt = (value / maxValue) * maxColumnHeight;

      final columnPaint = Paint()..color = Colors.blue;

      final left = i * columnWidth;
      final top = maxColumnHeight - columnHeigt;
      final column = Rect.fromLTWH(left, top, columnWidth, columnHeigt);

      canvas.drawRect(column, columnPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
