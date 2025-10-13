import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Circular progress ring widget for displaying completion progress.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    super.key,
    this.size = 120,
    this.strokeWidth = 12,
    this.color = const Color(0xFF6C63FF),
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.child,
    this.showPercentage = true,
    this.animated = true,
  });
  final double progress;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final Widget? child;
  final bool showPercentage;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress ring
          if (animated)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: progress),
              builder: (context, value, _) => CustomPaint(
                size: Size(size, size),
                painter: _ProgressRingPainter(
                  progress: value,
                  strokeWidth: strokeWidth,
                  color: color,
                  backgroundColor: backgroundColor,
                ),
              ),
            )
          else
            CustomPaint(
              size: Size(size, size),
              painter: _ProgressRingPainter(
                progress: progress,
                strokeWidth: strokeWidth,
                color: color,
                backgroundColor: backgroundColor,
              ),
            ),

          // Center content
          if (child != null)
            child!
          else if (showPercentage)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'Tamamlandı',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Custom painter for the progress ring.
class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    const startAngle = -math.pi / 2; // Start from top

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Animated progress ring with pulse effect.
class AnimatedProgressRing extends StatefulWidget {
  const AnimatedProgressRing({
    required this.progress,
    super.key,
    this.size = 120,
    this.strokeWidth = 12,
    this.color = const Color(0xFF6C63FF),
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.child,
    this.showPercentage = true,
  });
  final double progress;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final Widget? child;
  final bool showPercentage;

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.progress >= 1.0) {
      // Show pulse animation when complete
      return ScaleTransition(
        scale: _scaleAnimation,
        child: ProgressRing(
          progress: widget.progress,
          size: widget.size,
          strokeWidth: widget.strokeWidth,
          color: widget.color,
          backgroundColor: widget.backgroundColor,
          showPercentage: widget.showPercentage,
          child: widget.child,
        ),
      );
    }

    return ProgressRing(
      progress: widget.progress,
      size: widget.size,
      strokeWidth: widget.strokeWidth,
      color: widget.color,
      backgroundColor: widget.backgroundColor,
      showPercentage: widget.showPercentage,
      child: widget.child,
    );
  }
}
