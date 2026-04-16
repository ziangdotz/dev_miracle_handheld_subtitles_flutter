import 'package:dev_miracle_handheld_subtitles_flutter/views/handheld_subtitles/handheld_subtitles_run_preview.dart';
import 'package:dev_miracle_handheld_subtitles_flutter/views/widgets/run_page_right_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HandheldSubtitlesRunPage extends StatefulWidget {
  final Color bg; // 背景色
  final String text; // 文字
  final double size; // 大小比例
  final TextStyle? style; // 风格
  final double velocity; // 速度 (px/秒)
  final bool enableFlashingText;
  final bool enableDouYinText;

  const HandheldSubtitlesRunPage({
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
  State<HandheldSubtitlesRunPage> createState() =>
      _HandheldSubtitlesRunPageState();
}

class _HandheldSubtitlesRunPageState extends State<HandheldSubtitlesRunPage> {
  @override
  void initState() {
    super.initState();

    // 策略：页面初始化时，先保持竖屏状态渲染，等到 Widget 构建完成（即转场动画开始）后，再请求横屏。这样可以看到页面竖着滑上来，然后顺滑地旋转成横屏。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterFullscreen();
    });
  }

  @override
  void dispose() {
    // 退出页面时恢复系统 UI（但不在这里处理方向，方向在 pop 之前处理）
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 PopScope（Flutter 3.12+）拦截物理返回键
    return PopScope(
      // 禁止自动 pop
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleExit();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: null,
        body: Container(
          child: Listener(
            // 触摸时重新触发全屏
            onPointerDown: (_) => _enterFullscreen(),
            child: GestureDetector(
              // 确保空白区域也能响应点击
              behavior: HitTestBehavior.opaque,
              // 全局点击事件
              onTap: () => _showRunPageRightSheet(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: widget.bg,
                child: Center(
                  child: HandheldSubtitlesRunPreview(
                    bg: widget.bg,
                    text: widget.text,
                    style: widget.style,
                    size: widget.size,
                    velocity: widget.velocity,
                    enableFlashingText: widget.enableFlashingText,
                    enableDouYinText: widget.enableDouYinText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 进入全屏
  Future<void> _enterFullscreen({
    bool hideStatus = true,
    bool hideNavigation = true,
  }) async {
    /// 1. 设置横屏
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    /// 2. 设置沉浸式样式
    try {
      final overlays = <SystemUiOverlay>[
        if (!hideStatus) SystemUiOverlay.top,
        if (!hideNavigation) SystemUiOverlay.bottom,
      ];

      /// Step 1：先设置系统 UI 样式
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarIconBrightness:
              WidgetsBinding.instance.window.platformBrightness ==
                  Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          // iOS 状态栏亮度
          statusBarBrightness: Brightness.dark,
        ),
      );

      /// Step 2：再进入沉浸模式
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: overlays,
      );
    } catch (e) {
      print('Failed to enter fullscreen mode: $e');
    }
  }

  /// 退出逻辑
  Future<void> _handleExit() async {
    // // 先退出沉浸模式，避免旋转时的 UI 遮挡问题
    // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // 强制切回竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // 等待屏幕旋转动画播放完毕
    await Future.delayed(const Duration(milliseconds: 200));
    // 再执行退出操作
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// 显示右侧弹窗的方法
  void _showRunPageRightSheet(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RunPageRightSheetContent(
              onEditPressed: () async {
                print('clicked Edit');
                // 退出逻辑
                await _handleExit();
              },
              onExitPressed: () {
                SystemNavigator.pop();
              },
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 从右侧滑动效果
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 320),
        opaque: false,
        // 半透明遮罩
        barrierColor: const Color(0x8A101010),
      ),
    );
  }
}
