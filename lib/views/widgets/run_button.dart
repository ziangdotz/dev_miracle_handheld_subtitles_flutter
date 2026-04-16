import 'package:flutter/material.dart';

class RunButton extends StatefulWidget {
  final double height; // 按钮的高度
  final Future<void> Function() onPressed; // 按钮点击时执行的函数
  final Color backgroundColor; // 按钮的背景颜色
  final Color textColor; // 按钮的文本颜色
  final String text; // 按钮上显示的文本
  final double fontSize; // 按钮文本的字号
  final double letterSpacing; // 按钮的字间距，默认 4
  final Duration pressFeedbackDuration; // 点击后预留的反馈时长，保证水波纹可感知

  const RunButton({
    super.key,
    this.height = 45.0, // 默认按钮的高度 45.0
    required this.onPressed,
    this.backgroundColor = Colors.deepPurple, // 默认按钮的背景颜色 Colors.deepPurple
    this.textColor = Colors.white, // 默认按钮的文本颜色 Colors.white
    required this.text,
    this.fontSize = 18, // 默认按钮文本的字号 18
    this.letterSpacing = 4, // 默认按钮的字间距 4
    this.pressFeedbackDuration = const Duration(milliseconds: 90),
  });

  @override
  State<RunButton> createState() => _RunButtonState();
}

class _RunButtonState extends State<RunButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10.0);

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: AnimatedScale(
        scale: _isPressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withOpacity(
                  _isPressed ? 0.16 : 0.28,
                ),
                blurRadius: _isPressed ? 6 : 12,
                offset: Offset(0, _isPressed ? 2 : 5),
              ),
            ],
          ),
          child: Material(
            color: widget.backgroundColor,
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                // 给水波纹短暂展示时间，避免立即跳转导致反馈不可见
                await Future.delayed(widget.pressFeedbackDuration);
                await widget.onPressed();
              },
              onHighlightChanged: (value) {
                if (_isPressed == value) return;
                setState(() {
                  _isPressed = value;
                });
              },
              borderRadius: borderRadius,
              splashFactory: InkRipple.splashFactory,
              splashColor: widget.textColor.withOpacity(0.20),
              highlightColor: widget.textColor.withOpacity(0.06),
              hoverColor: widget.textColor.withOpacity(0.04),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: const Border.fromBorderSide(
                    BorderSide(color: Color(0x80101010), width: 1),
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.bold,
                      color: widget.textColor,
                      letterSpacing: widget.letterSpacing,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
