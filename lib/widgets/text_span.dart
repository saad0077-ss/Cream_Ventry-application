import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomTextSpan extends StatelessWidget {
  final List<TextSpanConfig> spans;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final TextStyle? defaultStyle;

  const CustomTextSpan({
    super.key,
    required this.spans,
    this.textAlign = TextAlign.left,
    this.overflow = TextOverflow.clip,
    this.maxLines,
    this.defaultStyle,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      text: TextSpan(
        style: defaultStyle ?? Theme.of(context).textTheme.bodyMedium,
        children: spans.map((config) {
          return TextSpan(
            text: config.text,
            style: config.style,
            recognizer: config.onTap != null
                ? (TapGestureRecognizer()..onTap = config.onTap)
                : null,
          );
        }).toList(),
      ),
    );
  }
}

class TextSpanConfig {
  final String text;
  final TextStyle? style;
  final VoidCallback? onTap;

  const TextSpanConfig({
    required this.text,
    this.style,
    this.onTap,
  });
}