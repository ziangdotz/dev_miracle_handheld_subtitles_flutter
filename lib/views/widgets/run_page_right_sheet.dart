import 'package:flutter/material.dart';

class RunPageRightSheetContent extends StatefulWidget {
  final VoidCallback onEditPressed;
  final VoidCallback onExitPressed;

  const RunPageRightSheetContent({
    super.key,
    required this.onEditPressed,
    required this.onExitPressed,
  });

  @override
  State<RunPageRightSheetContent> createState() =>
      _RunPageRightSheetContentState();
}

class _RunPageRightSheetContentState extends State<RunPageRightSheetContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _button1Animation;
  late Animation<double> _button2Animation;

  static const double _kBorderRadius = 24.0;
  static const EdgeInsets _kButtonPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 14.0,
  );
  static const Color _kPrimary = Color(0xFF101010);
  static const Color _kPanelBg = Color(0xFFF8F8F8);
  static const Color _kPanelBorder = Color(0xFFE9E9E9);
  static const Color _kDanger = Color(0xFFFF4D4F);
  static const Color _kDangerSoft = Color(0xFFFFF4F4);

  @override
  void initState() {
    super.initState();

    /// 初始化动画控制器
    _controller = AnimationController(
      duration: const Duration(milliseconds: 360),
      vsync: this,
    );

    /// 设置动画序列
    // Controller->>Opacity: 0.0-0.5 (淡入)
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );
    // Controller->>Slide: 从右侧弹性滑入（保持固定在右侧）
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    /// 按钮交错动画
    // Controller->>Button1: 0.3-0.7 (按钮 1 入场)
    _button1Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.70, curve: Curves.easeOut),
      ),
    );
    // Controller->>Button2: 0.5-0.9 (按钮 2 入场)
    _button2Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.90, curve: Curves.easeOut),
      ),
    );

    /// 启动动画
    _controller.forward();
  }

  @override
  void dispose() {
    // 释放动画资源
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panelWidth = MediaQuery.of(context).size.width * 0.66;

    return Stack(
      children: [
        // 半透明背景点击区域
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),
        ),
        // 右侧面板
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Container(
                width: panelWidth.clamp(240.0, 320.0),
                decoration: BoxDecoration(
                  color: _kPanelBg,
                  border: Border(
                    left: BorderSide(color: _kPanelBorder, width: 1),
                  ),
                  borderRadius: const BorderRadius.only(
                    // 左上角圆角
                    topLeft: Radius.circular(_kBorderRadius),
                    // 左下角圆角
                    bottomLeft: Radius.circular(_kBorderRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.16),
                      blurRadius: 24.0,
                      spreadRadius: 0.0,
                      offset: const Offset(-6, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  // 禁用左侧安全区域检测
                  left: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '操作面板',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w700,
                                      color: _kPrimary,
                                      decoration: TextDecoration.none,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => Navigator.of(context).pop(),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: _kPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildAnimatedButton(
                                context,
                                '修改样式',
                                Icons.edit,
                                widget.onEditPressed,
                                _button1Animation,
                                isPrimary: true,
                              ),
                              const SizedBox(height: 28.0),
                              _buildAnimatedButton(
                                context,
                                '退出程序',
                                Icons.power_settings_new,
                                widget.onExitPressed,
                                _button2Animation,
                                isDanger: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建带动画的按钮
  Widget _buildAnimatedButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
    Animation<double> animation, {
    bool isPrimary = false,
    bool isDanger = false,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(18 * (1 - animation.value), 0),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: _buildButton(
        context,
        text,
        icon,
        onPressed,
        isPrimary: isPrimary,
        isDanger: isDanger,
      ),
    );
  }

  /// 构建基础按钮
  Widget _buildButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed, {
    bool isPrimary = false,
    bool isDanger = false,
  }) {
    final Color backgroundColor;
    final Color foregroundColor;
    final Color borderColor;

    if (isPrimary) {
      backgroundColor = _kPrimary;
      foregroundColor = Colors.white;
      borderColor = _kPrimary;
    } else if (isDanger) {
      backgroundColor = _kDangerSoft;
      foregroundColor = _kDanger;
      borderColor = const Color(0xFFFFDCDD);
    } else {
      backgroundColor = Colors.white;
      foregroundColor = _kPrimary;
      borderColor = _kPanelBorder;
    }

    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 22),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor, width: 1),
          ),
          padding: _kButtonPadding,
          minimumSize: const Size(double.infinity, 56),
        ),
        onPressed: () async {
          Navigator.of(context).pop();
          await Future.delayed(const Duration(milliseconds: 220));
          onPressed();
        },
      ),
    );
  }
}
