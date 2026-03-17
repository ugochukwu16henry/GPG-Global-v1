import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/mock_data_provider.dart';
import 'glass_card.dart';

/// Profile card: Mission/Pathway status with Connect ↔ Degree toggle and confetti.
class ProfileCard extends ConsumerStatefulWidget {
  const ProfileCard({super.key});

  @override
  ConsumerState<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<ProfileCard> {
  ConfettiController? _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    super.dispose();
  }

  void _onToggleStatus() {
    final wasConnect = ref.read(profileProvider).pathwayStatus == PathwayStatus.connect;
    ref.read(profileProvider.notifier).toggleStatus();
    if (wasConnect) {
      _confettiController?.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.pathwayAmber.withValues(alpha: 0.3),
                    child: Text(
                      profile.displayName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textOnSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.missionName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: profile.pathwayStatus == PathwayStatus.degree
                      ? AppColors.pathwayAmber.withValues(alpha: 0.2)
                      : AppColors.primaryNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.pathwayStep,
                      style: TextStyle(
                        fontSize: 12,
                        color: profile.pathwayStatus == PathwayStatus.degree
                            ? AppColors.primaryNavy
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onToggleStatus,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          profile.pathwayStatus == PathwayStatus.connect
                              ? Icons.school_outlined
                              : Icons.workspace_premium_outlined,
                          size: 18,
                          color: AppColors.primaryNavy,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          profile.pathwayStatus == PathwayStatus.connect
                              ? 'Connect'
                              : 'Degree',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.swap_horiz,
                          size: 16,
                          color: AppColors.primaryNavy.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController!,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 24,
            emissionFrequency: 0.05,
            gravity: 0.15,
            colors: const [
              AppColors.pathwayAmber,
              AppColors.primaryNavy,
              AppColors.surfaceWhite,
            ],
            shouldLoop: false,
          ),
        ),
      ],
    );
  }
}
