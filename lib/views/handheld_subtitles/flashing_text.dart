import 'package:flutter/material.dart';

class FlashingText extends StatefulWidget {
  final String text; // 文字
  final TextStyle baseStyle; // 基础风格
  final Duration duration; // 动画时长

  const FlashingText({
    super.key,
    required this.text,
    required this.baseStyle,
    this.duration = const Duration(milliseconds: 300), // 默认动画时长 300 毫秒
  });

  @override
  State<FlashingText> createState() => _FlashingTextState();
}

class _FlashingTextState extends State<FlashingText> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  // 颜色序列
  static const List<Color> _colors = [
    Colors.white,
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();

    /// 动画时长可以设为 2 秒的循环时间
    _animationController = AnimationController(duration: const Duration(seconds: 2), vsync: this);

    /// 1. 创建 TweenSequenceItem 列表
    final List<TweenSequenceItem<Color?>> items = [];
    // 循环创建颜色对的渐变序列
    for (int i = 0; i < _colors.length; i++) {
      final Color beginColor = _colors[i];
      // 循环到下一个颜色
      final Color endColor = _colors[(i + 1) % _colors.length];
      // 每个颜色对占总时长的比例，这里设置为每个颜色对占 1/N；但为了让颜色从 A -> B 只需要一半时间，然后从 B -> C，我们将整个循环分为 N 个颜色对，每个 ColorTween 占用 1/N 的时间。
      items.add(
        TweenSequenceItem<Color?>(
          // 颜色从 A 渐变到 B
          tween: ColorTween(begin: beginColor, end: endColor),
          // 每个渐变步骤的权重。这里将总权重平均分配给 N 个颜色对。
          weight: 1.0,
        ),
      );
    }

    /// 2. 使用 TweenSequence 驱动颜色动画
    // 将总时长平均分配给所有颜色渐变步骤
    _colorAnimation = TweenSequence<Color?>(items).animate(_animationController);

    /// 3. 循环播放动画，不使用 reverse：true，而是让它始终从 0.0 播放到 1.0
    // 实现 A -> B -> C -> D -> ... 的顺序渐变。
    _animationController.repeat(reverse: false);
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        final Color animatedColor = _colorAnimation.value ?? Colors.white;
        return Text(
          widget.text,
          style: widget.baseStyle.copyWith(
            color: animatedColor,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                // 阴影颜色与文字颜色一致
                color: animatedColor.withOpacity(0.8),
                offset: const Offset(0, 0),
              ),
            ],
          ),
        );
      },
    );
  }
}
