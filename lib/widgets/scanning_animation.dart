import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class ScanningAnimation extends StatefulWidget {
  final double width;
  final double height;
  final Widget child; // The image being scanned

  const ScanningAnimation({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  State<ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<ScanningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Status messages to cycle through
  final List<String> _scanStatus = [
    'Scanning Code...',
    'Extracting Ingredients...',
    'Analyzing Additives...',
    'Verifying Claims...',
    'Detecting Lies...',
  ];
  int _statusIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Speed of one full sweep
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // Cycle text every 1.5 seconds
    _cycleText();
  }

  void _cycleText() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _statusIndex = (_statusIndex + 1) % _scanStatus.length;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // 1. The Image (Fills container)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: widget.child,
            ),
          ),

          // 2. Dark Overlay
          Container(color: Colors.black.withAlpha(77)),

          // 3. Scanning Beam
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: widget.height * _animation.value - 2, // -2 to center beam
                left: 0,
                right: 0,
                child: Container(
                  height: 4, // Beam thickness
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withAlpha(204),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [
                        AppColors.cyan.withAlpha(0),
                        AppColors.cyan,
                        AppColors.cyan.withAlpha(0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),

          // 4. Status Text (Bottom Center)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(179),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _scanStatus[_statusIndex],
                    key: ValueKey<int>(_statusIndex),
                    style: const TextStyle(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
