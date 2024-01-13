import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_la_libertad/widgets/note_icon.dart';

class DanceGesture extends StatefulWidget {
  const DanceGesture({
    Key? key,
    required this.child,
    this.onDoubleTap,
    this.onStop,
  }) : super(key: key);

  final Function? onDoubleTap;
  final Function? onStop;
  final Widget child;

  @override
  _DanceGestureState createState() => _DanceGestureState();
}

class _DanceGestureState extends State<DanceGesture> {
  final _key = GlobalKey();

  Offset _p(Offset p) {
    RenderBox getBox = _key.currentContext?.findRenderObject() as RenderBox;
    return getBox.globalToLocal(p);
  }

  List<Offset> icons = [];

  bool canAddNotes = false;
  bool justAddNotes = false;
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    var iconStack = Container(
      width: size.width,
      color: Colors.transparent,
      child: Stack(
        children: icons
            .map<Widget>(
              (p) => DanceAnimationIcon(
                position: p,
                onAnimationComplete: () {
                  icons.remove(p);
                },
              ),
            )
            .toList(),
      ),
    );
    return GestureDetector(
      key: _key,
      onTapDown: (detail) {
        setState(() {
          if (canAddNotes) {
            icons.add(_p(detail.globalPosition));
            widget.onDoubleTap?.call();
            justAddNotes = true;
          } else {
            justAddNotes = false;
          }
        });
      },
      onTapUp: (detail) {
        timer?.cancel();
        var delay = canAddNotes ? 1200 : 600;
        timer = Timer(Duration(milliseconds: delay), () {
          canAddNotes = false;
          timer = null;
          widget.onStop?.call();
        });
        canAddNotes = true;
      },
      child: Stack(
        children: <Widget>[
          widget.child,
          iconStack,
        ],
      ),
    );
  }
}

class DanceAnimationIcon extends StatefulWidget {
  final Offset position;
  final double size;
  final Function? onAnimationComplete;

  const DanceAnimationIcon({
    Key? key,
    this.onAnimationComplete,
    required this.position,
    this.size = 100,
  }) : super(key: key);

  @override
  _DanceAnimationIconState createState() => _DanceAnimationIconState();
}

class _DanceAnimationIconState extends State<DanceAnimationIcon>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _animationController = AnimationController(
      lowerBound: 0,
      upperBound: 1,
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _animationController?.addListener(() {
      setState(() {});
    });
    startAnimation();
    super.initState();
  }

  startAnimation() async {
    await _animationController?.forward();
    widget.onAnimationComplete?.call();
  }

  double rotate = pi / 10.0 * (2 * Random().nextDouble() - 1);

  double get value => _animationController?.value ?? 0;

  double appearDuration = 0.1;
  double dismissDuration = 0.2;

  double get opa {
    if (value < appearDuration) {
      return 0.99 / appearDuration * value;
    }
    if (value < dismissDuration) {
      return 0.99;
    }
    var res = 0.99 - (value - dismissDuration) / (1 - dismissDuration);
    return res < 0 ? 0 : res;
  }

  double get scale {
    if (value < appearDuration) {
      return 1 + appearDuration - value;
    }
    if (value < dismissDuration) {
      return 1;
    }
    return (value - dismissDuration) / (1 - dismissDuration) + 1;
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Transform.rotate(
      angle: rotate,
      child: Opacity(
        opacity: opa,
        child: Transform.scale(
          alignment: Alignment.bottomCenter,
          scale: scale,
          child: NoteIcon(size: widget.size),
        ),
      ),
    );
    return Positioned(
      left: widget.position.dx - widget.size / 2,
      top: widget.position.dy - widget.size / 2,
      child: body,
    );
  }
}
