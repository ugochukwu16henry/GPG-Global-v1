import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum LogoSurfaceVariant {
  appIcon,
  controlRoomMonochrome,
  birthdayGlow,
}

/// G-Nexus logo with pulse animation in the header.
class GNexusLogo extends StatefulWidget {
  const GNexusLogo({
    super.key,
    this.size = 36,
    this.variant = LogoSurfaceVariant.appIcon,
  });

  final double size;
  final LogoSurfaceVariant variant;

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
    final (background, border, textColor) = switch (widget.variant) {
      LogoSurfaceVariant.appIcon => (
          AppColors.primaryNavy.withValues(alpha: 0.9),
          AppColors.pathwayAmber.withValues(alpha: 0.5),
          AppColors.pathwayAmber,
        ),
      LogoSurfaceVariant.controlRoomMonochrome => (
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.4),
          Colors.white,
        ),
      LogoSurfaceVariant.birthdayGlow => (
          AppColors.primaryNavy.withValues(alpha: 0.9),
          AppColors.surfaceWhite.withValues(alpha: 0.8),
          AppColors.pathwayAmber,
        ),
    };

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
              color: background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: border,
                width: 1,
              ),
              boxShadow: widget.variant == LogoSurfaceVariant.birthdayGlow
                  ? [
                      BoxShadow(
                        color: AppColors.surfaceWhite.withValues(alpha: 0.55),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              'G',
              style: TextStyle(
                color: textColor,
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

class MeritBadge extends StatelessWidget {
  const MeritBadge({super.key, this.label = 'Merit Verified'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.stewardshipGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.stewardshipGreen.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GNexusLogo(size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.stewardshipGreen,
            ),
          ),
        ],
      ),
    );
  }
}
