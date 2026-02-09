import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiWidget extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const ConfettiWidget({
    super.key,
    required this.child,
    this.isPlaying = false,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _controller.addListener(_updateParticles);
    if (widget.isPlaying) {
      _startExplosion();
    }
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startExplosion();
    }
  }

  void _startExplosion() {
    _particles.clear();
    for (int i = 0; i < 50; i++) {
      _particles.add(ConfettiParticle(
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
        x: 0.5, // Center
        y: 0.5,
        vx: (_random.nextDouble() - 0.5) * 0.04,
        vy: (_random.nextDouble() - 0.5) * 0.04 - 0.02, // Upward bias
        size: _random.nextDouble() * 10 + 5,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
      ));
    }
    _controller.forward(from: 0);
  }

  void _updateParticles() {
    for (var p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.001; // Gravity
      p.rotation += p.rotationSpeed;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isPlaying)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ConfettiPainter(_particles),
              ),
            ),
          ),
      ],
    );
  }
}

class ConfettiParticle {
  Color color;
  double x, y, vx, vy, size, rotation, rotationSpeed;
  ConfettiParticle(
      {required this.color,
      required this.x,
      required this.y,
      required this.vx,
      required this.vy,
      required this.size,
      required this.rotation,
      required this.rotationSpeed});
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()..color = p.color;
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rotation);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
