// 虚线分割线组件
import 'package:flutter/material.dart';

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
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final maxWidth = constraints.maxWidth;
        return SizedBox(
          width: maxWidth,
          height: totalHeight,
          child: Row(
            children: List.generate(
              maxWidth ~/ (dashWidth * 2),
              (index) =>
                  Expanded(child: Container(color: index % 2 == 0 ? color : Colors.transparent)),
            ),
          ),
        );
      },
    );
  }
}
