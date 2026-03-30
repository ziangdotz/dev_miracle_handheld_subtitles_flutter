import 'package:dev_miracle_handheld_subtitles_flutter/views/handheld_subtitles/handheld_subtitles_text.dart';
import 'package:flutter/material.dart';

class HandheldSubtitlesRunPreview extends StatefulWidget {
  final Color bg; // 背景色
  final String text; // 文字
  final double size; // 大小比例
  final TextStyle? style; // 风格
  final double velocity; // 速度 (px/秒)
  final bool enableFlashingText;
  final bool enableDouYinText;

  const HandheldSubtitlesRunPreview({
    super.key,
    this.bg = const Color(0xFF101010), // 默认背景色
    required this.text,
    this.size = 0.60, // 默认大小比例 0.60
    this.style,
    this.velocity = 60.0, // 默认速度 60 px/秒
    this.enableFlashingText = false,
    this.enableDouYinText = false,
  });

  @override
  State<HandheldSubtitlesRunPreview> createState() => _HandheldSubtitlesRunPreviewState();
}

class _HandheldSubtitlesRunPreviewState extends State<HandheldSubtitlesRunPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _cachedText;
  double _cachedBoxWidth = 0.0;
  double _cachedTextWidth = 0.0;
  TextStyle? _cachedEffectiveStyle;
  // 固定的滚动文字后的间隔（占位），50 px
  static const double _gap = 50.0;

  @override
  void initState() {
    super.initState();

    // 创建控制器，持续时间设为非常大以模拟无限运行
    _animationController = AnimationController(vsync: this, duration: const Duration(days: 365))
      ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 获取当前容器的宽度
        final boxWidth = constraints.maxWidth;
        // 高度 Height = Width / (21 / 9)
        final double boxHeight = boxWidth / (21 / 9);
        // 只有当尺寸或文本发生变化时才重新计算，节省性能
        if (_cachedText != widget.text || _cachedBoxWidth != boxWidth) {
          _cachedBoxWidth = boxWidth;
          _cachedText = widget.text;
          // 计算目标字体大小
          final double targetFontSize = boxHeight * widget.size;
          _cachedEffectiveStyle = (widget.style ?? const TextStyle(color: Colors.white)).copyWith(
            fontSize: targetFontSize,
            height: 1.0,
          );
          // 计算文本宽度
          _cachedTextWidth = _measureText(context, widget.text, _cachedEffectiveStyle!);
        }

        // 处理空文本情况
        if (_cachedTextWidth == 0.0) {
          return Container(
            height: boxHeight,
            color: widget.bg,
            alignment: Alignment.center,
            child: Text(widget.text, style: _cachedEffectiveStyle),
          );
        }

        final loopWidth = _cachedBoxWidth + _cachedTextWidth + _gap;

        // 预先构建好静态的 Row，不在 AnimationBuilder 内部反复 New
        final Widget staticScrollingContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 占位符
            SizedBox(width: _cachedBoxWidth),
            // 文本：当前正在显示的文本
            HandheldSubtitlesText(
              widget.text,
              style: _cachedEffectiveStyle,
              enableFlashingText: widget.enableFlashingText,
              enableDouYinText: widget.enableDouYinText,
            ),
            // 占位符
            SizedBox(width: _gap),
          ],
        );

        return Container(
          decoration: BoxDecoration(color: widget.bg, borderRadius: BorderRadius.circular(16)),
          child: AspectRatio(
            // AspectRatio 保持 21:9 的比例
            aspectRatio: 21 / 9,
            // ClipRect 确保超出的内容被裁剪，不会绘制到容器外面
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _animationController,
                // 使用 OverflowBox 允许子组件宽度无限大
                child: OverflowBox(
                  minWidth: 0,
                  maxWidth: double.infinity,
                  // 从左侧开始对齐
                  alignment: Alignment.centerLeft,
                  child: staticScrollingContent,
                ),
                builder: (context, child) {
                  /// 1. 计算当前累积滚动的总像素距离
                  final double totalDistance =
                      (_animationController.lastElapsedDuration?.inMilliseconds ?? 0) /
                      1000.0 *
                      widget.velocity;

                  /// 2. 计算当前周期的偏移量 dx
                  // 使用 % loopWidth 确保 dx 在 [0, loopWidth] 之间循环；取负号是因为要向左移动
                  final double dx = -(totalDistance % loopWidth);

                  /// 3. 实现水平滚动效果
                  return Transform.translate(offset: Offset(dx, 0), child: child);
                  // /// 3. 创建 SingleChildScrollView 实现水平滚动效果
                  // return Center(
                  //   child: SingleChildScrollView(
                  //     scrollDirection: Axis.horizontal,
                  //     // 禁止用户手动滚动
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     child: Transform.translate(
                  //       offset: Offset(dx, 0),
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           // 占位符
                  //           SizedBox(width: boxWidth),
                  //           // 文本
                  //           HandheldSubtitlesText(
                  //             widget.text,
                  //             style: effectiveStyle,
                  //             enableFlashingText: widget.enableFlashingText,
                  //             enableDouYinText: widget.enableDouYinText,
                  //           ),
                  //           // 占位符
                  //           SizedBox(width: _gap),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// 计算文本宽度（使用 TextPainter）
  double _measureText(BuildContext context, String text, TextStyle style) {
    // 获取系统的字体缩放比例
    final textScaler = MediaQuery.of(context).textScaler;

    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();
    return tp.width;
  }
}
