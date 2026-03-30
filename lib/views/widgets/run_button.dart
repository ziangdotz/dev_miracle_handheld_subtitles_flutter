import 'package:flutter/material.dart';

class RunButton extends StatefulWidget {
  final double height; // 按钮的高度
  final Future<void> Function() onPressed; // 按钮点击时执行的函数
  final Color backgroundColor; // 按钮的背景颜色
  final Color textColor; // 按钮的文本颜色
  final String text; // 按钮上显示的文本
  final double fontSize; // 按钮文本的字号
  final double letterSpacing; // 按钮的字间距，默认 4

  const RunButton({
    super.key,
    this.height = 45.0, // 默认按钮的高度 45.0
    required this.onPressed,
    this.backgroundColor = Colors.deepPurple, // 默认按钮的背景颜色 Colors.deepPurple
    this.textColor = Colors.white, // 默认按钮的文本颜色 Colors.white
    required this.text,
    this.fontSize = 18, // 默认按钮文本的字号 18
    this.letterSpacing = 4, // 默认按钮的字间距 4
  });

  @override
  State<RunButton> createState() => _RunButtonState();
}

class _RunButtonState extends State<RunButton> {
  // 存储原始的颜色状态，用于恢复
  late final Color _originalBgColor;
  late final Color _originalTextColor;
  // 存储当前的颜色状态
  late Color _currentBgColor;
  late Color _currentTextColor;

  @ override
  void initState() {
    super.initState();

    // 初始化原始颜色和当前颜色
    _originalBgColor = widget.backgroundColor;
    _originalTextColor = widget.textColor;
    _currentBgColor = widget.backgroundColor;
    _currentTextColor = widget.textColor;
  }

  @override
  void didUpdateWidget(covariant RunButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.backgroundColor != oldWidget.backgroundColor || widget.textColor != oldWidget.textColor) {
      // 只有在未按下状态时才同步外部传入的颜色变化
      if (_currentBgColor == _originalBgColor) {
        _currentBgColor = widget.backgroundColor;
        _currentTextColor = widget.textColor;
      }
      _originalBgColor = widget.backgroundColor;
      _originalTextColor = widget.textColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox(
          width: double.infinity,
          height: widget.height,
          child: ElevatedButton(
            onPressed: () async {
              // 先互换背景颜色和文本颜色
              if (mounted) {
                setState(() {
                  final temp = _currentBgColor;
                  _currentBgColor = _currentTextColor;
                  _currentTextColor = temp;
                });
              }
              // 等待 150 毫秒
              await Future.delayed(const Duration(milliseconds: 150));
              // 再执行外部操作，并等待其完成
              await widget.onPressed();
              // 最后再恢复背景颜色和文本颜色
              if (mounted) {
                setState(() {
                  _currentBgColor = _originalBgColor;
                  _currentTextColor = _originalTextColor;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentBgColor,
              foregroundColor: _currentTextColor,
              side: BorderSide(color: const Color(0x80101010), width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              elevation: 5,
              shadowColor: _currentBgColor.withOpacity(0.3),
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                color: _currentTextColor,
                letterSpacing: widget.letterSpacing,
              ),
            ),
          ),
        );
      },
    );
  }
}
