import 'package:dev_miracle_handheld_subtitles_flutter/views/handheld_subtitles/shaking_text.dart';
import 'package:dev_miracle_handheld_subtitles_flutter/views/handheld_subtitles/flashing_text.dart';
import 'package:flutter/material.dart';

class HandheldSubtitlesText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final bool enableFlashingText; // 是否启用闪烁效果 Text
  final bool enableDouYinText; // 是否启用仿抖音 Text

  const HandheldSubtitlesText(
    this.data, {
    super.key,
    this.style,
    this.enableFlashingText = false,
    this.enableDouYinText = false,
  });

  @override
  Widget build(BuildContext context) {
    if (enableFlashingText) {
      return FlashingText(text: data, baseStyle: style ?? DefaultTextStyle.of(context).style);
    } else if (enableDouYinText) {
      return ShakingText(text: data, baseStyle: style ?? DefaultTextStyle.of(context).style);
    } else {
      return Text(data, style: style);
    }
  }
}
