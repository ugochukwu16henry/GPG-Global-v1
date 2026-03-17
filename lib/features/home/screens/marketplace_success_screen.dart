import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MarketplaceSuccessPayload {
  const MarketplaceSuccessPayload({
    required this.name,
    required this.skillName,
    required this.location,
    required this.listingId,
  });

  final String name;
  final String skillName;
  final String location;
  final String listingId;
}

class MarketplaceSuccessScreen extends StatefulWidget {
  const MarketplaceSuccessScreen({
    super.key,
    required this.payload,
  });

  final MarketplaceSuccessPayload payload;

  @override
  State<MarketplaceSuccessScreen> createState() => _MarketplaceSuccessScreenState();
}

class _MarketplaceSuccessScreenState extends State<MarketplaceSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final AnimationController _badgeController;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..forward();

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    final random = Random(22);
    _particles = List.generate(
      34,
      (index) => _ConfettiParticle(
        angle: random.nextDouble() * 2 * pi,
        speed: 70 + random.nextDouble() * 150,
        size: 6 + random.nextDouble() * 6,
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.payload;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, _) {
                final progress = Curves.easeOut.transform(_confettiController.value);
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: progress,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Your Talent is Live! 🌟',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.pathwayAmber,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Congratulations, ${payload.name}! Your listing as a ${payload.skillName} is now visible to the global GPG community.\n'
                        'By sharing your skills, you aren\'t just building a career—you\'re strengthening the gathering. '
                        'We\'ve notified users in your ${payload.location} that a new trusted professional is available.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, height: 1.45),
                      ),
                      const SizedBox(height: 18),
                      _listingPreview(payload),
                      const SizedBox(height: 14),
                      ScaleTransition(
                        scale: CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
                        child: RotationTransition(
                          turns: Tween<double>(begin: -0.2, end: 0).animate(
                            CurvedAnimation(parent: _badgeController, curve: Curves.easeOutBack),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Chip(
                              avatar: const Icon(Icons.verified_rounded, color: AppColors.stewardshipGreen),
                              backgroundColor: AppColors.stewardshipGreen.withValues(alpha: 0.18),
                              label: const Text(
                                'Verified Listing',
                                style: TextStyle(
                                  color: AppColors.stewardshipGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.tonal(
                            onPressed: () => Navigator.of(context).pushNamed('/talent/${payload.listingId}'),
                            child: const Text('View My Listing'),
                          ),
                          FilledButton.tonal(
                            onPressed: () => Navigator.of(context)
                                .pushNamed('/mission-group/nigeria-lagos-mission-reunion'),
                            child: const Text('Share to My Mission Group'),
                          ),
                          FilledButton.tonal(
                            onPressed: () => Navigator.of(context)
                                .pushNamedAndRemoveUntil('/', (route) => false),
                            child: const Text('Go to Dashboard'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listingPreview(MarketplaceSuccessPayload payload) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171A22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.pathwayAmber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.work_rounded, color: AppColors.pathwayAmber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${payload.skillName} · ${payload.name}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  payload.location,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.size,
  });

  final double angle;
  final double speed;
  final double size;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.25);
    final palette = [
      AppColors.pathwayAmber,
      AppColors.stewardshipGreen,
      Colors.white,
    ];

    for (var index = 0; index < particles.length; index++) {
      final particle = particles[index];
      final radius = particle.speed * progress;
      final dx = cos(particle.angle) * radius;
      final dy = sin(particle.angle) * radius + progress * 90;
      final paint = Paint()
        ..color = palette[index % palette.length].withValues(alpha: (1 - progress).clamp(0, 1));
      canvas.drawCircle(center + Offset(dx, dy), particle.size * (1 - progress * 0.35), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
