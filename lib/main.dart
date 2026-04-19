import 'dart:async';
import 'package:dev_miracle_handheld_subtitles_flutter/views/handheld_subtitles/shaking_text.dart';
import 'package:dev_miracle_handheld_subtitles_flutter/views/handheld_subtitles/flashing_text.dart';
import 'package:dev_miracle_handheld_subtitles_flutter/views/handheld_subtitles/handheld_subtitles_run_preview.dart';
import 'package:dev_miracle_handheld_subtitles_flutter/views/handheld_subtitles/handheld_subtitles_run_page.dart';
import 'package:dev_miracle_handheld_subtitles_flutter/views/widgets/dashed_divider.dart';
import 'package:dev_miracle_handheld_subtitles_flutter/views/widgets/run_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '手持字幕',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFF8F8F8)),
        useMaterial3: true,
      ),
      home: const HandheldSubtitlesPage(),
    );
  }
}

class HandheldSubtitlesPage extends StatefulWidget {
  const HandheldSubtitlesPage({super.key});

  @override
  State<HandheldSubtitlesPage> createState() => _HandheldSubtitlesPageState();
}

class _HandheldSubtitlesPageState extends State<HandheldSubtitlesPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();

  // 颜色主题配置
  final List<Map<String, dynamic>> _colorTheme = [
    {
      'bg': const Color(0xFF101010),
      'text': const Color(0xFFF8F8F8),
      'name': '黑底白字',
    },
    {
      'bg': const Color(0xFF101010),
      'text': const Color(0xFFFF4D4F),
      'name': '黑底红字',
    },
    {
      'bg': const Color(0xFF101010),
      'text': const Color(0xFF00FF29),
      'name': '黑底绿字',
    },
    {
      'bg': const Color(0xFF000A7B),
      'text': const Color(0xFFF8F8F8),
      'name': '蓝底白字',
    },
    {'bg': const Color(0xFF101010), 'name': '闪烁效果'},
    {'bg': const Color(0xFF101010), 'name': '抖动效果'},
  ];

  // 字体配置列表
  final List<Map<String, dynamic>> _fontChoose = [
    {'label': '默认', 'family': 'Din'},
    {'label': '方正·简', 'family': 'FangZheng-JianTi'},
    {'label': '卡通', 'family': 'HanYiZhiYan-KaTong'},
    {'label': '得意黑', 'family': 'SmileySans'},
  ];

  // 大小配置列表
  final List<Map<String, dynamic>> _fontSize = [
    {'label': '较小', 'size': 13.0, 'value': 0.45},
    {'label': '适中', 'size': 14.0, 'value': 0.60},
    {'label': '较大', 'size': 16.0, 'value': 0.75},
    {'label': '全屏', 'size': 18.0, 'value': 1.00},
  ];

  int _selectedColorThemeIndex = 0;
  int _selectedFontChooseIndex = 0;
  int _selectedFontSizeIndex = 1;
  double _speed = 2.0;

  @override
  void initState() {
    super.initState();

    // 强制竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 延迟全屏
    Future.delayed(Duration.zero, () {
      _enterFullscreen();
    });
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    _textController.dispose();

    // 恢复默认屏幕方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // 退出页面时恢复系统 UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        if (_textFieldFocusNode.hasFocus) {
          _textFieldFocusNode.unfocus();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          toolbarHeight: 60.0,
          backgroundColor: const Color(0xFFF8F8F8),
          elevation: 0,
          // 保持标题居中
          centerTitle: true,
          // 设置 leading 的宽度 = 图标大小(24) + 左边距(20) = 44
          leadingWidth: 44.0,
          // 移除标题周围的默认间距，防止标题过长时位置偏移
          titleSpacing: 0,
          title: const Text(
            '手持字幕',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101010),
            ),
          ),
          leading: const SizedBox.shrink(),
          actions: [const SizedBox(width: 20.0)],
        ),

        /// 保证键盘弹出时页面能滚动
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 0,
                  bottom: 34.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 1. 预览
                    _buildPreview(),

                    /// 2. 输入框
                    Container(
                      height: 90,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0.0,
                        vertical: 5.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          border: Border.all(color: const Color(0xFFEBEBEB)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: TextField(
                          controller: _textController,
                          focusNode: _textFieldFocusNode,
                          // 允许多行
                          maxLines: null,
                          onChanged: (val) {
                            // 触发 UI 刷新以更新预览
                            setState(() {});
                          },
                          // 光标颜色
                          cursorColor: const Color(0xFF101010),
                          // 光标粗细
                          cursorWidth: 1,
                          // 圆角光标
                          cursorRadius: const Radius.circular(2),
                          decoration: const InputDecoration(
                            hintText: "输入字幕... ...",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const DashedDivider(
                      color: Color(0xFFEBEBEB),
                      totalHeight: 1.0,
                      dashWidth: 2.0,
                    ),

                    /// 3. 颜色选择（横向滚动）
                    Container(
                      width: double.infinity,
                      height: 59,
                      padding: const EdgeInsets.only(
                        top: 13.0,
                        bottom: 13.0,
                        left: 0.0,
                        right: 0.0,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_colorTheme.length, (index) {
                            final item = _colorTheme[index];
                            final isSelected =
                                _selectedColorThemeIndex == index;
                            return GestureDetector(
                              onTap: () => setState(
                                () => _selectedColorThemeIndex = index,
                              ),
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 70),
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  // 按钮背景色
                                  color: item['bg'],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? item['bg']
                                        : const Color(0x80BBBBBB),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: (item['name'] == '闪烁效果')
                                    ? FlashingText(
                                        text: item['name'],
                                        baseStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : (item['name'] == '抖动效果')
                                    ? ShakingText(
                                        text: item['name'],
                                        baseStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text(
                                        item['name'],
                                        style: TextStyle(
                                          // 按钮文字颜色
                                          color: item['text'],
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const DashedDivider(
                      color: Color(0xFFEBEBEB),
                      totalHeight: 1.0,
                      dashWidth: 2.0,
                    ),

                    /// 4. 字体选择
                    _buildOptionRow(
                      label: "字  体：",
                      items: _fontChoose,
                      selectedIndex: _selectedFontChooseIndex,
                      onItemSelected: (index) {
                        setState(() => _selectedFontChooseIndex = index);
                      },
                    ),
                    const DashedDivider(
                      color: Color(0xFFEBEBEB),
                      totalHeight: 1.0,
                      dashWidth: 2.0,
                    ),

                    /// 5. 大小选择
                    _buildOptionRow(
                      label: "大  小：",
                      items: _fontSize,
                      selectedIndex: _selectedFontSizeIndex,
                      onItemSelected: (index) {
                        setState(() => _selectedFontSizeIndex = index);
                      },
                    ),
                    const DashedDivider(
                      color: Color(0xFFEBEBEB),
                      totalHeight: 1.0,
                      dashWidth: 2.0,
                    ),

                    /// 6. 速度调节
                    Container(
                      padding: const EdgeInsets.only(
                        top: 13.0,
                        bottom: 13.0,
                        left: 0.0,
                        right: 0.0,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "速  度：",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF101010),
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF101010),
                                inactiveTrackColor: const Color(0xFFE0E0E0),
                                thumbColor: const Color(0xFF101010),
                                overlayColor: const Color(
                                  0xFF101010,
                                ).withOpacity(0.2),
                                trackHeight: 3.0,
                                // 去掉左右 24 逻辑像素的默认 padding
                                trackShape: const RoundedRectSliderTrackShape(),
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 10,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 0,
                                ),
                                valueIndicatorShape:
                                    const PaddleSliderValueIndicatorShape(),
                                valueIndicatorColor: const Color(0xFF101010),
                                showValueIndicator: ShowValueIndicator.always,
                              ),
                              child: Slider(
                                value: _speed,
                                min: 0.5,
                                max: 5.0,
                                label: "${_speed.toStringAsFixed(1)}x",
                                onChanged: (val) {
                                  setState(() {
                                    _speed = val;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 7. 运行按钮
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 34),
              child: RunButton(
                text: '运  行',
                onPressed: () => _doRun(context),
                backgroundColor: const Color(0xFF101010),
                textColor: const Color(0xFFF8F8F8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 进入全屏
  Future<void> _enterFullscreen() async {
    try {
      // 设置系统 UI 样式
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
    } catch (e) {
      print('Failed to enter fullscreen mode: $e');
    }
  }

  /// 构建预览区域
  Widget _buildPreview() {
    final displayText = _textController.text.isEmpty
        ? "输入字幕... ..."
        : _textController.text;
    final currentColorTheme = _colorTheme[_selectedColorThemeIndex];
    final currentFontChoose = _fontChoose[_selectedFontChooseIndex];
    final currentFontSize =
        _fontSize[_selectedFontSizeIndex]['value'] as double;
    final enableFlashingText = currentColorTheme['name'] == '闪烁效果';
    final enableDouYinText = currentColorTheme['name'] == '抖动效果';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: HandheldSubtitlesRunPreview(
        key: ValueKey(
          "preview_$_selectedColorThemeIndex$_selectedFontChooseIndex$_selectedFontSizeIndex$_speed",
        ),
        bg: currentColorTheme['bg'],
        text: displayText,
        size: currentFontSize,
        style: TextStyle(
          color: currentColorTheme['text'],
          fontFamily: currentFontChoose['family'],
          fontSize: currentFontSize,
        ),
        // 基准速度是 60 px/秒
        velocity: _speed * 60,
        enableFlashingText: enableFlashingText,
        enableDouYinText: enableDouYinText,
      ),
    );
  }

  /// 构建通用的横向滚动选项行
  Widget _buildOptionRow({
    required String label,
    required List<dynamic> items,
    required int selectedIndex,
    required Function(int) onItemSelected,
  }) {
    return Container(
      width: double.infinity,
      height: 59,
      padding: const EdgeInsets.only(
        top: 13.0,
        bottom: 13.0,
        left: 0.0,
        right: 0.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, color: Color(0xFF101010)),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = selectedIndex == index;

                  final labelText = item is Map
                      ? item['label']
                      : item.toString();
                  final fontSize = item is Map
                      ? item['size']?.toDouble() ?? 14.0
                      : 14.0;
                  final fontFamily = item is Map
                      ? item['family'] ?? 'Din'
                      : 'Din';

                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: InkWell(
                      onTap: () => onItemSelected(index),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 70),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0x80101010)
                                : const Color(0x80BBBBBB),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            // 使用统一处理的 label
                            labelText,
                            style: TextStyle(
                              // 动态字号
                              fontSize: fontSize,
                              // 动态字体
                              fontFamily: fontFamily,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: const Color(0xFF101010),
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 点击“运行”按钮，执行的方法
  Future<void> _doRun(BuildContext context) async {
    // 进入运行页前主动移除焦点，避免返回时系统恢复焦点并弹出键盘。
    _textFieldFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    final displayText = _textController.text.isEmpty
        ? "输入字幕... ..."
        : _textController.text;
    final currentColorTheme = _colorTheme[_selectedColorThemeIndex];
    final currentFontChoose = _fontChoose[_selectedFontChooseIndex];
    final currentFontSize =
        _fontSize[_selectedFontSizeIndex]['value'] as double;
    final enableFlashingText = currentColorTheme['name'] == '闪烁效果';
    final enableDouYinText = currentColorTheme['name'] == '抖动效果';

    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            HandheldSubtitlesRunPage(
              bg: currentColorTheme['bg'],
              text: displayText,
              size: currentFontSize,
              style: TextStyle(
                color: currentColorTheme['text'],
                fontFamily: currentFontChoose['family'],
                fontSize: currentFontSize,
              ),
              // 基准速度是 60 px/秒
              velocity: _speed * 60,
              enableFlashingText: enableFlashingText,
              enableDouYinText: enableDouYinText,
            ),
        fullscreenDialog: true,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 从底部滑动效果
          const slideBegin = Offset(0.0, 1.0);
          const slideEnd = Offset.zero;
          final slideTween = Tween(
            begin: slideBegin,
            end: slideEnd,
          ).chain(CurveTween(curve: Curves.easeOutQuart));
          final slideAnimation = animation.drive(slideTween);
          return SlideTransition(position: slideAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    // 从运行页返回后再次清理焦点，防止回退动画结束时焦点自动恢复。
    _textFieldFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
