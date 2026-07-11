import 'package:flutter/material.dart';

class BubblyBackground extends StatelessWidget {
  const BubblyBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFDFF9FF),
            Color(0xFFECFEFF),
            Color(0xFFFFF7ED),
          ],
        ),
      ),
      child: Stack(
        children: [
          const _Bubble(
            size: 220,
            top: -72,
            left: -54,
            color: Color(0x55BAE6FD),
          ),
          const _Bubble(
            size: 180,
            top: 120,
            right: -68,
            color: Color(0x66A7F3D0),
          ),
          const _Bubble(
            size: 140,
            bottom: 30,
            left: -30,
            color: Color(0x66FBCFE8),
          ),
          const _Bubble(
            size: 120,
            bottom: 160,
            right: 40,
            color: Color(0x66FDE68A),
          ),
          child,
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.size,
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.color,
  });

  final double size;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
      ),
    );
  }
}
