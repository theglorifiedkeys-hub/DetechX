import 'package:flutter/material.dart';

/// Reveals whole grapheme clusters while reserving the final bubble size.
class TypingReply extends StatelessWidget {
  const TypingReply(this.text, {required this.style, super.key});
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context))
      return Text(text, style: style);
    final characters = text.characters;
    return Semantics(
      label: text,
      liveRegion: true,
      excludeSemantics: true,
      child: TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: characters.length),
        duration: Duration(
          milliseconds: (characters.length * 17).clamp(250, 1300).toInt(),
        ),
        child: Opacity(opacity: 0, child: Text(text, style: style)),
        builder: (context, count, sizingText) => Stack(
          children: [
            sizingText!,
            Positioned.fill(
              child: Text(characters.take(count).toString(), style: style),
            ),
          ],
        ),
      ),
    );
  }
}
