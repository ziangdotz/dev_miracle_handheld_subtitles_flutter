import 'package:flutter/material.dart';

class SubtitlesConfig {
  final Color bg;
  final String text;
  final double size;
  final TextStyle? style;
  final double velocity;
  final bool enableFlashingText;
  final bool enableDouYinText;

  const SubtitlesConfig({
    required this.bg,
    required this.text,
    this.size = 0.60,
    this.style,
    this.velocity = 60.0,
    this.enableFlashingText = false,
    this.enableDouYinText = false,
  });
}
