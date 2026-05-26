import 'package:dev_miracle_handheld_subtitles_flutter/models/subtitles_config.dart';
import 'package:dev_miracle_handheld_subtitles_flutter/views/handheld_subtitles/handheld_subtitles_run_preview.dart';
import 'package:dev_miracle_handheld_subtitles_flutter/views/widgets/run_page_right_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HandheldSubtitlesRunPage extends StatefulWidget {
  final SubtitlesConfig config;

  const HandheldSubtitlesRunPage({
    super.key,
    required this.config,
  });

  @override
  State<HandheldSubtitlesRunPage> createState() =>
      _HandheldSubtitlesRunPageState();
}

class _HandheldSubtitlesRunPageState extends State<HandheldSubtitlesRunPage> {
  bool _fullscreenEntered = false;
  bool _hasEnteredImmersive = false;
  Route? _sheetRoute;

  @override
  void initState() {
    super.initState();

    _enterFullscreen();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleExit();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: null,
        body: Listener(
            onPointerDown: (_) => _enterFullscreen(),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showRunPageRightSheet(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: widget.config.bg,
                child: Center(
                  child: Hero(
                    tag: 'run_preview',
                    child: HandheldSubtitlesRunPreview(
                      config: widget.config,
                    ),
                  ),
                ),
              ),
            ),
        ),
      ),
    );
  }

  Future<void> _enterFullscreen() async {
    try {
      if (!_fullscreenEntered) {
        _fullscreenEntered = true;

        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);

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
            statusBarBrightness: Brightness.dark,
          ),
        );

        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
        );

        _hasEnteredImmersive = true;
        Future.delayed(const Duration(milliseconds: 400), () {
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.immersiveSticky,
          );
        });
      } else if (_hasEnteredImmersive) {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky,
        );
      }
    } catch (e) {
      print('Failed to enter fullscreen mode: $e');
    }
  }

  Future<void> _handleExit() async {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showRunPageRightSheet(BuildContext context) {
    if (_sheetRoute != null) return;

    final route = PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          RunPageRightSheetContent(
        onEditPressed: () async {
          print('clicked Edit');
          await _handleExit();
        },
        onExitPressed: () {
          SystemNavigator.pop();
        },
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
      barrierColor: const Color(0x8A101010),
    );

    _sheetRoute = route;

    Navigator.of(context).push(route).whenComplete(() {
      _sheetRoute = null;
    });
  }
}
