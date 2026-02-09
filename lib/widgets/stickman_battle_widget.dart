import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class StickmanBattleWidget extends StatefulWidget {
  const StickmanBattleWidget({super.key});

  @override
  State<StickmanBattleWidget> createState() => _StickmanBattleWidgetState();
}

class _StickmanBattleWidgetState extends State<StickmanBattleWidget>
    with TickerProviderStateMixin {
  late AnimationController _combatController;
  int _attackType = 0; // 0 = Punch, 1 = Kick
  final List<_LieBubble> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _combatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Spawn bubbles continuously
    _spawnBubbles();
  }

  void _spawnBubbles() async {
    if (!mounted) return;

    while (mounted) {
      await Future.delayed(Duration(milliseconds: 1200 + _random.nextInt(800)));
      if (!mounted) break;

      // Determine attack type: 0=Punch (40%), 1=Kick (40%), 2=Shoot (20%)
      int rand = _random.nextInt(100);
      int nextAttack = rand < 40
          ? 0
          : rand < 80
              ? 1
              : 2;

      // Impact timings (based on 2000ms bubble duration)
      // Punch/Kick: Impact at 0.7 (1400ms) -> Start Anim at 1250ms
      // Shoot: Impact at 0.3 (600ms) -> Start Anim at 450ms
      double impactProgress = nextAttack == 2 ? 0.3 : 0.7;
      int delayMs = nextAttack == 2 ? 450 : 1250;

      setState(() {
        _bubbles.add(_LieBubble(
          text: _marketingLies[_random.nextInt(_marketingLies.length)],
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          attackType: nextAttack,
          // Punch is high (Stack 110), Kick is low (Stack 60), Shoot is mid (Stack 90)
          // Text bottom logic: targetY + 40
          // Punch: targetY 70 -> bottom 110.
          // Kick: targetY 20 -> bottom 60.
          // Shoot: targetY 50 -> bottom 90.
          targetY: nextAttack == 0
              ? 70.0
              : nextAttack == 1
                  ? 20.0
                  : 50.0, // Shoot mid height
          impactProgress: impactProgress,
        ));
      });

      // Time the attack to hit exactly when bubble arrives (Impact at 1400ms for melee, 600ms for gun)
      // Animation duration 300ms, peak at 150ms.
      // Start at (Impact Time) - 150ms.
      Future.delayed(Duration(milliseconds: delayMs), () {
        if (mounted) {
          setState(() => _attackType = nextAttack);
          _combatController
              .forward(from: 0)
              .then((_) => _combatController.reverse());
        }
      });

      // Remove bubble after animation
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() {
            if (_bubbles.isNotEmpty) _bubbles.removeAt(0);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _combatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.black, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: CustomPaint(painter: GridPainter()),
            ),

            // The Stickman
            Positioned(
              left: 50,
              bottom: 50,
              child: AnimatedBuilder(
                animation: _combatController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(100, 120),
                    painter: StickmanPainter(
                      progress: _combatController.value,
                      attackType: _attackType,
                    ),
                  );
                },
              ),
            ),

            // Incoming Lies
            ..._bubbles.map((bubble) =>
                _AnimatedLieBubble(key: ValueKey(bubble.id), bubble: bubble)),

            // Footer Badge
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.danger, width: 2),
                  ),
                  child: const Text(
                    'WE FIGHT THE LIES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.danger,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gray.withOpacity(0.05)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StickmanPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 (Attack extension)
  final int attackType; // 0 = Punch, 1 = Kick, 2 = Shoot

  StickmanPainter({required this.progress, required this.attackType});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.black
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final headPaint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.fill;

    // Base Position
    const centerX = 30.0;
    const bodyTopY = 30.0;
    const bodyBottomY = 80.0;

    // Impact shift (move body forward slightly during attack)
    final shiftX = progress * 10;

    // Head
    canvas.drawCircle(Offset(centerX + shiftX, 15), 12, headPaint);

    // Body
    canvas.drawLine(Offset(centerX + shiftX, bodyTopY),
        Offset(centerX + shiftX, bodyBottomY), paint);

    // Legs
    // Left Leg (Anchor)
    canvas.drawLine(Offset(centerX + shiftX, bodyBottomY),
        Offset(centerX + shiftX - 15, 110), paint);

    // Right Leg (Active)
    if (attackType == 1) {
      // KICK ANIMATION
      // Knee raises then extends
      final kneeX = centerX + shiftX + 10 + (progress * 20);
      final kneeY = bodyBottomY + 10 - (progress * 15);
      final footX = kneeX + (progress * 65); // Kick extended further to hit
      final footY = kneeY + (progress * 10); // Slightly down

      canvas.drawLine(Offset(centerX + shiftX, bodyBottomY),
          Offset(kneeX, kneeY), paint); // Thigh
      canvas.drawLine(
          Offset(kneeX, kneeY), Offset(footX, footY), paint); // Calf
    } else {
      // Normal stance
      canvas.drawLine(Offset(centerX + shiftX, bodyBottomY),
          Offset(centerX + shiftX + 15, 110), paint);
    }

    // Arms
    // Left Arm (Guard)
    canvas.drawLine(Offset(centerX + shiftX, bodyTopY + 10),
        Offset(centerX + shiftX - 10, bodyTopY + 30), paint);
    canvas.drawLine(Offset(centerX + shiftX - 10, bodyTopY + 30),
        Offset(centerX + shiftX + 10, bodyTopY + 15), paint);

    // Right Arm (Active)
    if (attackType == 2) {
      // GUN ANIMATION
      // Arm extended straight
      final shoulder = Offset(centerX + shiftX, bodyTopY + 10);
      final hand = Offset(shoulder.dx + 40, shoulder.dy);
      canvas.drawLine(shoulder, hand, paint);

      // Draw Gun
      final gunPaint = Paint()
        ..color = AppColors.black
        ..style = PaintingStyle.fill;
      canvas.drawRect(
          Rect.fromLTWH(hand.dx, hand.dy - 5, 20, 10), gunPaint); // Barrel
      canvas.drawRect(
          Rect.fromLTWH(hand.dx, hand.dy, 8, 12), gunPaint); // Handle

      // Muzzle Flash (only at peak of animation)
      if (progress > 0.5) {
        final flashPaint = Paint()
          ..color = AppColors.yellow
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
            Offset(hand.dx + 25, hand.dy), 8 + (progress * 5), flashPaint);
      }
    } else if (attackType == 0) {
      // PUNCH ANIMATION
      // Shoulder to Elbow to Hand
      final shoulder = Offset(centerX + shiftX, bodyTopY + 10);
      final elbow = Offset(shoulder.dx + 15 + (progress * 10), shoulder.dy + 5);
      final hand = Offset(elbow.dx + 20 + (progress * 40),
          elbow.dy - (progress * 5)); // Punch straight/up

      canvas.drawLine(shoulder, elbow, paint);
      canvas.drawLine(elbow, hand, paint);
    } else {
      // Normal stance (or Kick upper body)
      canvas.drawLine(Offset(centerX + shiftX, bodyTopY + 10),
          Offset(centerX + shiftX + 15, bodyTopY + 35), paint);
    }
  }

  @override
  bool shouldRepaint(covariant StickmanPainter oldDelegate) => true;
}

const List<String> _marketingLies = [
  "100% NATURAL",
  "ZERO SUGAR",
  "HEALTHY",
  "MIRACLE",
  "NO FAT",
  "ORGANIC",
  "REAL FRUIT",
  "GLUTEN FREE",
  "VITAMIN ENRICHED",
  "FARM FRESH",
  "ARTISAN",
  "NO ADDED SUGAR",
  "GUILT FREE",
  "PROBIOTIC",
];

class _LieBubble {
  final String text;
  final String id;
  final int attackType;
  final double targetY;
  final double impactProgress;

  _LieBubble(
      {required this.text,
      required this.id,
      required this.attackType,
      required this.targetY,
      required this.impactProgress});
}

class _AnimatedLieBubble extends StatefulWidget {
  final _LieBubble bubble;

  const _AnimatedLieBubble({required Key key, required this.bubble})
      : super(key: key);

  @override
  State<_AnimatedLieBubble> createState() => _AnimatedLieBubbleState();
}

class _AnimatedLieBubbleState extends State<_AnimatedLieBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    // Pre-generate particles
    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(
        dx: (_random.nextDouble() - 0.5) * 60, // Random spread X
        dy: (_random.nextDouble() - 0.5) * 60, // Random spread Y
        speed: 2 + _random.nextDouble() * 4,
        theta: _random.nextDouble() * 2 * pi,
        size: 2 + _random.nextDouble() * 3,
        color: AppColors.black.withOpacity(0.5 + _random.nextDouble() * 0.5),
      ));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Fly from Right (350) to Left (Impact Zone varies)
        const double startX = 350;
        final double impactX = widget.bubble.attackType == 2 ? 250.0 : 110.0;

        double progress = _controller.value;
        double impactTime = widget.bubble.impactProgress;

        // Phase 1: Flying in
        if (progress <= impactTime) {
          final double currentX =
              startX - ((startX - impactX) * (progress / impactTime));
          return Positioned(
            left: currentX,
            bottom: widget.bubble.targetY + 40,
            child: Text(
              widget.bubble.text,
              style: GoogleFonts.spaceGrotesk(
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  shadows: [
                    const Shadow(
                        color: Colors.black12,
                        offset: Offset(1, 1),
                        blurRadius: 1),
                  ]),
            ),
          );
        } else {
          // Phase 2: Shattered (Particles)
          // Calculate time since impact (0.0 to 1.0 relative to remaining time)
          // Actually, let's just use raw progress difference scaled up
          double shatterProgress = (progress - impactTime) / (1.0 - impactTime);
          if (shatterProgress > 1.0) shatterProgress = 1.0;

          return Positioned(
            left: impactX, // Burst center
            bottom:
                widget.bubble.targetY + 40 + 10, // approximate center of text
            child: CustomPaint(
              painter: DustPainter(
                particles: _particles,
                progress: shatterProgress,
              ),
            ),
          );
        }
      },
    );
  }
}

class _Particle {
  final double dx;
  final double dy;
  final double speed;
  final double theta;
  final double size;
  final Color color;

  _Particle(
      {required this.dx,
      required this.dy,
      required this.speed,
      required this.theta,
      required this.size,
      required this.color});
}

class DustPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress; // 0.0 to 1.0

  DustPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;

    // Explosion expansion
    final double expansion = progress * 50;

    for (var p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity((1.0 - progress).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      // Move particle outwards
      final double x = cos(p.theta) * p.speed * expansion;
      final double y = sin(p.theta) * p.speed * expansion;

      canvas.drawCircle(Offset(x, y), p.size * (1.0 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant DustPainter oldDelegate) => true;
}
