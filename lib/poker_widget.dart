import 'dart:ui';

import 'package:flutter/material.dart';

class PokerWidget extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int>? onChanged;
  final int length;
  final double width;
  final double height;
  final double ratio;
  final double radius;

  const PokerWidget({
    super.key,
    required this.itemBuilder,
    required this.length,
    required this.width,
    required this.height,
    this.onChanged,
    this.ratio = 419 / 612,
    this.radius = 16,
  });

  @override
  State<PokerWidget> createState() => _PokerWidgetState();
}

class _PokerWidgetState extends State<PokerWidget>
    with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  Animation<double>? _animation;

  double _currentPage = 0.0;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _currentPage -= details.primaryDelta! * 0.01;
      _currentPage = _currentPage.clamp(0, widget.length - 1);
      _animationController
        ..removeListener(_animationListener)
        ..reset();
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0;
    int targetPage = _currentPage.round();

    if (velocity.abs() >= 500) {
      targetPage += velocity > 0 ? -1 : 1;
    }

    targetPage = targetPage.clamp(0, widget.length - 1);
    _animateToPage(targetPage);
  }

  void _animateToPage(int targetIndex) {
    if (_animationController.isAnimating) return;

    _animationController
      ..removeListener(_animationListener)
      ..removeStatusListener(_animationStatusListener)
      ..reset();
    _animation =
        Tween<double>(begin: _currentPage, end: targetIndex.toDouble()).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            ),
          )
          ..addListener(_animationListener)
          ..addStatusListener(_animationStatusListener);
    _animationController.forward();
  }

  void _animationListener() {
    setState(() {
      _currentPage = _animation!.value;
    });
  }

  void _animationStatusListener(AnimationStatus status) {
    if(status == AnimationStatus.completed){
      widget.onChanged?.call(_currentPage.round());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: SizedBox(
        height: widget.height,
        child: Stack(alignment: Alignment.centerLeft, children: buildCards()),
      ),
    );
  }

  // Calculate card position based on its index and current page
  double calcLeft(
    int index,
    double currentPage,
    double inactiveGap,
    double offset,
  ) {
    double factor = (index - currentPage).clamp(0.0, 1.0);
    return index * inactiveGap + offset * factor;
  }

  List<Widget> buildCards() {
    final activeWidth = widget.ratio * widget.height;
    final inactiveWidth = activeWidth * 0.8;
    final totalAvailableWidth = widget.width - activeWidth;
    final inactiveGap = totalAvailableWidth / (widget.length - 1);
    final double offset = activeWidth - inactiveWidth;

    final list = List.generate(widget.length, (index) => index);
    list.sort((a, b) {
      return (b - _currentPage).abs().compareTo((a - _currentPage).abs());
    });
    return list.map((index) {
      double left = calcLeft(index, _currentPage, inactiveGap, offset);
      double distance = (index - _currentPage).abs();
      double scaleFactor = 0.8 + (0.2 * (1 - distance.clamp(0, 1)));
      return Positioned(
        left: left,
        child: Transform(
          alignment: Alignment.centerLeft,
          transform: Matrix4.identity()..scale(scaleFactor, scaleFactor),
          child: _buildCard(index, distance),
        ),
      );
    }).toList();
  }

  // Generates a color filter based on distance (for fading effect)
  ColorFilter getSaturationColorFilter(double t) {
    final List<double> identity = <double>[
      1, 0, 0, 0, 0, // R
      0, 1, 0, 0, 0, // G
      0, 0, 1, 0, 0, // B
      0, 0, 0, 1, 0, // A
    ];

    final List<double> grayscale = <double>[
      0.2126, 0.7152, 0.0722, 0, 0, //R
      0.2126, 0.7152, 0.0722, 0, 0, //G
      0.2126, 0.7152, 0.0722, 0, 0, //B
      0, 0, 0, 1, 0, //A
    ];

    final List<double> result = List<double>.generate(20, (index) {
      return lerpDouble(identity[index], grayscale[index], t)!;
    });

    return ColorFilter.matrix(result);
  }

  Widget _buildCard(int index, double distance) {
    double t = distance.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        _animateToPage(index);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: ColorFiltered(
          colorFilter: getSaturationColorFilter(t),
          child: SizedBox(
            height: widget.height,
            child: widget.itemBuilder(context, index),
          ),
        ),
      ),
    );
  }
}
