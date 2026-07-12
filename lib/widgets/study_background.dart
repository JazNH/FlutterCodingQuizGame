import 'package:flutter/material.dart';

class StudyBackground extends StatelessWidget {
  const StudyBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F4E8),
            Color(0xFFF4EFE1),
            Color(0xFFEDE7D4),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _NotebookLinesPainter(),
            ),
          ),
          const Positioned(
            top: 52,
            left: 18,
            child: _Sticky(color: Color(0xFFFED7AA), angle: -0.08),
          ),
          const Positioned(
            top: 115,
            right: 20,
            child: _Sticky(color: Color(0xFFBFDBFE), angle: 0.12),
          ),
          const Positioned(
            bottom: 56,
            left: 30,
            child: _Sticky(color: Color(0xFFBBF7D0), angle: -0.12),
          ),
          child,
        ],
      ),
    );
  }
}

class _Sticky extends StatelessWidget {
  const _Sticky({required this.color, required this.angle});

  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotebookLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 34.0;
    final linePaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.42)
      ..strokeWidth = 1;

    for (double y = 18; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final marginPaint = Paint()
      ..color = const Color(0xFFFCA5A5).withValues(alpha: 0.45)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(72, 0), Offset(72, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
