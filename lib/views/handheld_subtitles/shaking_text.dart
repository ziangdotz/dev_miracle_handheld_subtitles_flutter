import 'dart:math';

import 'package:flutter/material.dart';

class ShakingText extends StatefulWidget {
  final String text; // 文字
  final TextStyle baseStyle; // 基础风格
  final Duration duration; // 动画时长
  final double maxOffset; // 最大偏移量

  const ShakingText({
    super.key,
    required this.text,
    required this.baseStyle,
    this.duration = const Duration(milliseconds: 500), // 默认动画时长 500 毫秒
    this.maxOffset = 5.0, // 默认最大偏移量 5.0
  });

  @override
  State<ShakingText> createState() => _ShakingTextState();
}

class _ShakingTextState extends State<ShakingText> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _redOffsetAnimation;
  late Animation<Offset> _cyanOffsetAnimation;
  late Animation<Offset> _whiteOffsetAnimation;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // 主动画控制器
    _animationController = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    // 透明度动画
    _opacityAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // 为每层文字创建独立的偏移动画
    _redOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _generateRandomOffset(),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _cyanOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _generateRandomOffset(),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _whiteOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _generateRandomOffset(),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // 监听动画值变化，更新随机偏移
    _animationController.addListener(() {
      if (_animationController.status == AnimationStatus.completed ||
          _animationController.status == AnimationStatus.dismissed) {
        setState(() {
          _redOffsetAnimation = Tween<Offset>(
            begin: _redOffsetAnimation.value,
            end: _generateRandomOffset(),
          ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

          _cyanOffsetAnimation = Tween<Offset>(
            begin: _cyanOffsetAnimation.value,
            end: _generateRandomOffset(),
          ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

          _whiteOffsetAnimation = Tween<Offset>(
            begin: _whiteOffsetAnimation.value,
            end: _generateRandomOffset(),
          ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // 红色描边（最底层）- 最大偏移
            Transform.translate(
              offset: _redOffsetAnimation.value,
              child: Text(
                widget.text,
                style: widget.baseStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..color = Colors.pink.withOpacity(_opacityAnimation.value)
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 6,
                ),
              ),
            ),
            // 青色描边（中间层）- 中等偏移
            Transform.translate(
              offset: _cyanOffsetAnimation.value,
              child: Text(
                widget.text,
                style: widget.baseStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..color = Colors.cyan.withOpacity(_opacityAnimation.value)
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 3,
                ),
              ),
            ),
            // 白色填充（顶层）- 最小偏移
            Transform.translate(
              offset: _whiteOffsetAnimation.value,
              child: Text(
                widget.text,
                style: widget.baseStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(_opacityAnimation.value),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 生成随机偏移量
  Offset _generateRandomOffset() {
    return Offset(
      (_random.nextDouble() * 2 - 1) * widget.maxOffset, // -maxOffset 到 maxOffset
      (_random.nextDouble() * 2 - 1) * widget.maxOffset,
    );
  }
}
