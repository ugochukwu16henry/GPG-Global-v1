import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// G-Nexus logo with pulse animation in the header.
class GNexusLogo extends StatefulWidget {
  const GNexusLogo({super.key, this.size = 36});

  final double size;

  @override
  State<GNexusLogo> createState() => _GNexusLogoState();
}

class _GNexusLogoState extends State<GNexusLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.pathwayAmber.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'G',
              style: TextStyle(
                color: AppColors.pathwayAmber,
                fontSize: widget.size * 0.55,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
