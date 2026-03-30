import 'package:flutter/material.dart';

class RunPageRightSheetContent extends StatefulWidget {
  final VoidCallback onEditPressed;
  final VoidCallback onExitPressed;

  const RunPageRightSheetContent({super.key, required this.onEditPressed, required this.onExitPressed});

  @override
  State<RunPageRightSheetContent> createState() => _RunPageRightSheetContentState();
}

class _RunPageRightSheetContentState extends State<RunPageRightSheetContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _button1Animation;
  late Animation<double> _button2Animation;

  static const double _kBorderRadius = 20.0;
  static const EdgeInsets _kButtonPadding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);

  bool _isEditButtonClicked = false;
  bool _isExitButtonClicked = false;

  @override
  void initState() {
    super.initState();

    /// 初始化动画控制器
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    /// 设置动画序列
    // Controller->>Opacity: 0.0-0.5 (淡入)
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    // Controller->>Slide: 从右侧弹性滑入（保持固定在右侧）
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    /// 按钮交错动画
    // Controller->>Button1: 0.3-0.7 (按钮 1 入场)
    _button1Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    // Controller->>Button2: 0.5-0.9 (按钮 2 入场)
    _button2Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
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
                width: 240.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: const BorderRadius.only(
                    // 左上角圆角
                    topLeft: Radius.circular(_kBorderRadius),
                    // 左下角圆角
                    bottomLeft: Radius.circular(_kBorderRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30.0,
                      spreadRadius: 10.0,
                      offset: const Offset(-5, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  // 禁用左侧安全区域检测
                  left: false,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 210.0,
                          height: 60.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '操作',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                  // 明确指定无装饰
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, size: 24),
                                onPressed: () => Navigator.of(context).pop(),
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        _buildAnimatedButton(
                          context,
                          '修改样式',
                          Icons.edit,
                          () {
                            setState(() {
                              _isEditButtonClicked = true;
                              _isExitButtonClicked = false;
                            });
                            widget.onEditPressed();
                          },
                          _button1Animation,
                          _isEditButtonClicked,
                        ),
                        const SizedBox(height: 20.0),
                        _buildAnimatedButton(
                          context,
                          '退出程序',
                          Icons.power_settings_new,
                          () {
                            setState(() {
                              _isExitButtonClicked = true;
                              _isEditButtonClicked = false;
                            });
                            widget.onExitPressed();
                          },
                          _button2Animation,
                          _isExitButtonClicked,
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
    Animation<double> animation,
    bool isClicked,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - animation.value), 0),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: _buildButton(context, text, icon, onPressed, isClicked),
    );
  }

  /// 构建基础按钮
  Widget _buildButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
    bool isClicked,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
      style:
          ElevatedButton.styleFrom(
            backgroundColor: isClicked ? Colors.deepPurple : Colors.white,
            foregroundColor: isClicked ? Colors.white : Colors.deepPurple,
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_kBorderRadius),
              side: BorderSide(color: Colors.deepPurple.withOpacity(0.1), width: 1),
            ),
            padding: _kButtonPadding,
            // 设置固定高度
            minimumSize: const Size(210, 54.0),
          ).copyWith(
            // 禁用水波纹效果
            splashFactory: NoSplash.splashFactory,
          ),
      onPressed: () async {
        // 先退出页面
        Navigator.of(context).pop();
        // 等待页面退出动画播放完毕
        await Future.delayed(const Duration(milliseconds: 300));
        // 再执行操作
        if (context.mounted) {
          onPressed();
        }
      },
    );
  }
}
