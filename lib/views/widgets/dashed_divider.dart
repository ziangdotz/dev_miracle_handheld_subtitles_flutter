// 虚线分割线组件
import 'package:flutter/material.dart';

class _DashedDividerPainter extends CustomPainter {
  final Color color;
  final double dashWidth;

  const _DashedDividerPainter({required this.color, required this.dashWidth});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    final gap = dashWidth;
    double startX = 0;
    final centerY = size.height / 2;

    while (startX < size.width) {
      final endX = (startX + dashWidth).clamp(0.0, size.width).toDouble();
      canvas.drawLine(Offset(startX, centerY), Offset(endX, centerY), paint);
      startX += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.dashWidth != dashWidth;
  }
}

class DashedDivider extends StatelessWidget {
  final Color color; // 虚线颜色
  final double totalHeight; // 厚度
  final double dashWidth; // 单段虚线长度

  const DashedDivider({
    super.key,
    this.color = const Color(0xFFBBBBBB),
    this.totalHeight = 1.0,
    this.dashWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: totalHeight,
      child: CustomPaint(
        painter: _DashedDividerPainter(color: color, dashWidth: dashWidth),
      ),
    );
  }
}
