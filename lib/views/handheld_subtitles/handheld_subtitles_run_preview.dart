import 'package:dev_miracle_handheld_subtitles_flutter/models/subtitles_config.dart';
import 'package:dev_miracle_handheld_subtitles_flutter/views/handheld_subtitles/handheld_subtitles_text.dart';
import 'package:flutter/material.dart';

class HandheldSubtitlesRunPreview extends StatefulWidget {
  final SubtitlesConfig config;

  const HandheldSubtitlesRunPreview({
    super.key,
    required this.config,
  });

  @override
  State<HandheldSubtitlesRunPreview> createState() =>
      _HandheldSubtitlesRunPreviewState();
}

class _HandheldSubtitlesRunPreviewState
    extends State<HandheldSubtitlesRunPreview>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  String? _cachedText;
  double _cachedBoxWidth = 0.0;
  double _cachedTextWidth = 0.0;
  TextStyle? _cachedEffectiveStyle;
  static const double _gap = 50.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _animationController =
        AnimationController(vsync: this, duration: const Duration(days: 365))
          ..repeat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _animationController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _animationController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.maxWidth;
        final double boxHeight = boxWidth / (21 / 9);
        if (_cachedText != widget.config.text || _cachedBoxWidth != boxWidth) {
          _cachedBoxWidth = boxWidth;
          _cachedText = widget.config.text;
          final double targetFontSize = boxHeight * widget.config.size;
          _cachedEffectiveStyle =
              (widget.config.style ?? const TextStyle(color: Colors.white))
                  .copyWith(
            fontSize: targetFontSize,
            height: 1.0,
          );
          _cachedTextWidth =
              _measureText(context, widget.config.text, _cachedEffectiveStyle!);
        }

        if (_cachedTextWidth == 0.0) {
          return Container(
            height: boxHeight,
            color: widget.config.bg,
            alignment: Alignment.center,
            child: Text(widget.config.text, style: _cachedEffectiveStyle),
          );
        }

        final loopWidth = _cachedBoxWidth + _cachedTextWidth + _gap;

        final Widget staticScrollingContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: _cachedBoxWidth),
            HandheldSubtitlesText(
              widget.config.text,
              style: _cachedEffectiveStyle,
              enableFlashingText: widget.config.enableFlashingText,
              enableDouYinText: widget.config.enableDouYinText,
            ),
            SizedBox(width: _gap),
          ],
        );

        return Container(
          decoration: BoxDecoration(
              color: widget.config.bg,
              borderRadius: BorderRadius.circular(16)),
          child: AspectRatio(
            aspectRatio: 21 / 9,
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _animationController,
                child: OverflowBox(
                  minWidth: 0,
                  maxWidth: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: staticScrollingContent,
                ),
                builder: (context, child) {
                  final double totalDistance =
                      (_animationController.lastElapsedDuration
                                  ?.inMilliseconds ??
                              0) /
                          1000.0 *
                      widget.config.velocity;

                  final double dx = -(totalDistance % loopWidth);

                  return Transform.translate(
                      offset: Offset(dx, 0), child: child);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  double _measureText(BuildContext context, String text, TextStyle style) {
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
