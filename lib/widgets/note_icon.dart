import 'package:flutter/material.dart';

class NoteIcon extends StatelessWidget {
  final double? size;
  const NoteIcon({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (Rect bounds) => RadialGradient(
        center: Alignment.topLeft.add(
          const Alignment(0.66, 0.66),
        ),
        colors: const [
          Color(0xFFb41917),
          Color(0xFFea4421),
          Color(0xffe94420),
          Color(0xfffbbe01),
        ],
      ).createShader(bounds),
      child: Icon(
        Icons.music_note_rounded,
        size: size,
        color: Colors.blue,
      ),
    );
  }
}
