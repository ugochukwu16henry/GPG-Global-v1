import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../backend/providers/backend_live_providers.dart';
import '../screens/privacy_safety_screen.dart';
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
  late final TextEditingController _phoneController;
  late final TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _phoneController = TextEditingController();
    _otpController = TextEditingController();
  }

  Future<void> _persistProfile() async {
    final profile = ref.read(profileProvider);
    final gateway = ref.read(backendGatewayProvider);
    final userId = ref.read(backendUserIdProvider);

    try {
      await gateway.setUserProfile(
        userId: userId,
        displayName: profile.displayName,
        isMember: profile.memberStatusLabel == 'Member',
        missionId: 'demo-mission-id',
        servedMission: profile.servedMission,
        pathwayStatus: profile.pathwayStatus == PathwayStatus.connect ? 'CONNECT' : 'DEGREE',
        isPathwayConnect: profile.isPathwayConnect,
        isDegree: profile.isDegree,
        isAlumni: profile.isAlumni,
        academicFocus: profile.academicFocus,
        country: profile.country,
        state: profile.state,
        lga: profile.lga,
        relationshipStatus:
            profile.relationshipStatus == RelationshipStatus.single ? 'SINGLE' : 'MARRIED',
        gender: profile.gender == Gender.male ? 'MALE' : 'FEMALE',
        allowsBirthdayBroadcast: profile.allowsBirthdayBroadcast,
        safeSearchFemaleOnly: profile.safeSearchFemaleOnly,
        safeSearchVerifiedMembersOnly: profile.safeSearchVerifiedMembersOnly,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile sync failed: $error')),
      );
    }
  }

  Future<void> _persistVisibility(String fieldKey, VisibilityLevel level) async {
    final gateway = ref.read(backendGatewayProvider);
    final userId = ref.read(backendUserIdProvider);
    final visibility = switch (level) {
      VisibilityLevel.everyone => 'EVERYONE',
      VisibilityLevel.connections => 'CONNECTIONS',
      VisibilityLevel.onlyMe => 'ONLY_ME',
    };

    try {
      await gateway.setFieldVisibility(
        userId: userId,
        fieldKey: fieldKey,
        visibility: visibility,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Visibility sync failed: $error')),
      );
    }
  }

  Future<void> _persistSafetyMode({
    required bool femaleOnly,
    required bool verifiedMembersOnly,
  }) async {
    final gateway = ref.read(backendGatewayProvider);
    final userId = ref.read(backendUserIdProvider);

    try {
      await gateway.setSafetyMode(
        userId: userId,
        femaleOnly: femaleOnly,
        verifiedMembersOnly: verifiedMembersOnly,
      );
      await _persistProfile();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Safety mode sync failed: $error')),
      );
    }
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onToggleStatus() {
    final wasConnect = ref.read(profileProvider).pathwayStatus == PathwayStatus.connect;
    ref.read(profileProvider.notifier).toggleStatus();
    _persistProfile();
    if (wasConnect) {
      _confettiController?.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final auth = ref.watch(backendAuthControllerProvider);
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
                        _persistProfile();
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
                        _persistProfile();
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
                        _persistProfile();
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
                        _persistSafetyMode(
                          femaleOnly: value,
                          verifiedMembersOnly: profile.safeSearchVerifiedMembersOnly,
                        );
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
                        _persistSafetyMode(
                          femaleOnly: profile.safeSearchFemaleOnly,
                          verifiedMembersOnly: value,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 20),
              const Text(
                'Phone Verification (OTP)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  labelText: 'Phone Number',
                  hintText: '+2348012345678',
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        labelText: 'OTP Code',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: auth.isLoading
                        ? null
                        : () {
                            ref
                                .read(backendAuthControllerProvider.notifier)
                                .sendOtp(_phoneController.text.trim());
                          },
                    child: const Text('Send OTP'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonal(
                  onPressed: auth.isLoading
                      ? null
                      : () {
                          ref.read(backendAuthControllerProvider.notifier).verifyOtp(
                                phone: _phoneController.text.trim(),
                                otpCode: _otpController.text.trim(),
                              );
                        },
                  child: const Text('Verify OTP & Use Account'),
                ),
              ),
              if (auth.devOtpPreview != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Dev OTP preview: ${auth.devOtpPreview}',
                  style: const TextStyle(fontSize: 10, color: AppColors.pathwayAmber),
                ),
              ],
              if (auth.message != null) ...[
                const SizedBox(height: 4),
                Text(
                  auth.message!,
                  style: const TextStyle(fontSize: 10, color: AppColors.stewardshipGreen),
                ),
              ],
              if (auth.error != null) ...[
                const SizedBox(height: 4),
                Text(
                  auth.error!,
                  style: const TextStyle(fontSize: 10, color: AppColors.warmCrimson),
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacySafetyScreen(),
                      ),
                    );
                  },
                  child: const Text('Open Privacy & Safety'),
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
    return PopupMenuButton<VisibilityLevel>(
      onSelected: (nextLevel) {
        final fieldKey = switch (field) {
          'Blood Group' => 'bloodGroup',
          'Genotype' => 'genotype',
          _ => 'age',
        };
        ref.read(profileProvider.notifier).setVisibility(fieldKey, nextLevel);
        _persistVisibility(fieldKey, nextLevel);
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: VisibilityLevel.everyone,
          child: Text('Everyone'),
        ),
        PopupMenuItem(
          value: VisibilityLevel.connections,
          child: Text('Connections'),
        ),
        PopupMenuItem(
          value: VisibilityLevel.onlyMe,
          child: Text('Only Me'),
        ),
      ],
      child: Container(
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
      ),
    );
  }
}
