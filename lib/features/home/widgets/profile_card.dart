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
              Text(
                profile.bio,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _pill('Location', '${profile.country}, ${profile.state}, ${profile.lga}'),
                  _pill('Relationship', profile.relationshipStatus.name),
                  _pill('Gender', profile.gender.name),
                  _pill('Age', profile.age?.toString() ?? 'N/A'),
                  _pill('Member', profile.memberStatusLabel),
                ],
              ),
              const SizedBox(height: 8),
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
              Row(
                children: [
                  Expanded(
                    child: _toggleChip(
                      label: 'Pathway Connect',
                      value: profile.isPathwayConnect,
                      onChanged: (value) {
                        ref.read(profileProvider.notifier).setPathwayJourney(
                              isPathwayConnect: value,
                            );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _toggleChip(
                      label: 'Degree',
                      value: profile.isDegree,
                      onChanged: (value) {
                        ref.read(profileProvider.notifier).setPathwayJourney(isDegree: value);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _toggleChip(
                      label: 'Alumni',
                      value: profile.isAlumni,
                      onChanged: (value) {
                        ref.read(profileProvider.notifier).setPathwayJourney(isAlumni: value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Educational Journey · ${profile.academicFocus}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _privacyChip('Blood Group', profile.visibilityByField['bloodGroup'] ?? VisibilityLevel.onlyMe),
                  _privacyChip('Genotype', profile.visibilityByField['genotype'] ?? VisibilityLevel.onlyMe),
                  _privacyChip('Age', profile.visibilityByField['age'] ?? VisibilityLevel.onlyMe),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _toggleChip(
                      label: 'Female Safety Mode',
                      value: profile.safeSearchFemaleOnly,
                      onChanged: (value) {
                        ref.read(profileProvider.notifier).setSafetyMode(femaleOnly: value);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _toggleChip(
                      label: 'Verified Members Only',
                      value: profile.safeSearchVerifiedMembersOnly,
                      onChanged: (value) {
                        ref
                            .read(profileProvider.notifier)
                            .setSafetyMode(verifiedMembersOnly: value);
                      },
                    ),
                  ),
                ],
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

  Widget _pill(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$title: $value',
        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
      ),
    );
  }

  Widget _toggleChip({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: value
              ? AppColors.stewardshipGreen.withValues(alpha: 0.18)
              : AppColors.primaryNavy.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: value ? AppColors.stewardshipGreen : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _privacyChip(String field, VisibilityLevel level) {
    final color = switch (level) {
      VisibilityLevel.everyone => AppColors.stewardshipGreen,
      VisibilityLevel.connections => AppColors.pathwayAmber,
      VisibilityLevel.onlyMe => AppColors.warmCrimson,
    };
    final label = switch (level) {
      VisibilityLevel.everyone => 'Everyone',
      VisibilityLevel.connections => 'Connections',
      VisibilityLevel.onlyMe => 'Only Me',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$field · $label',
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
