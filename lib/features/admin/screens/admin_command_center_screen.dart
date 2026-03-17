import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/session_provider.dart';
import '../providers/admin_command_center_provider.dart';

class AdminCommandCenterScreen extends ConsumerWidget {
  const AdminCommandCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(adminCommandControllerProvider);
    final activeRole = ref.watch(activeAdminRoleProvider);
    final backendError = ref.watch(adminCommandErrorProvider);

    final aiPulse = ref.watch(mergedAiPulseProvider);
    final heatMap = ref.watch(friendSignupHeatmapProvider);
    final reviewQueue = ref.watch(rapidReviewQueueProvider);
    final registrationVelocity = ref.watch(registrationVelocityProvider);
    final onlineHeatmap = ref.watch(globalOnlineHeatmapProvider);
    final ecosystem = ref.watch(ecosystemValueProvider);

    final vaultUsers = ref.watch(vaultUsersProvider);
    final selectedQuery = ref.watch(selectedAdminQueryPresetProvider);
    final advancedResults = ref.watch(advancedSearchResultsProvider);

    final genotypeAlerts = ref.watch(genotypePrivacyAlertsProvider);
    final riskList = ref.watch(highBlockRiskListProvider);
    final managedUsers = ref.watch(managedUsersProvider);
    final blacklistedPhones = ref.watch(blacklistedPhonesProvider);
    final blacklistedDevices = ref.watch(blacklistedDevicesProvider);
    final breakGlassDesk = ref.watch(breakGlassDeskControllerProvider);

    final revenue = ref.watch(pendingRevenueUsdProvider);
    final revenueByCategory = ref.watch(marketplaceRevenueByCategoryProvider);
    final birthdayQueue = ref.watch(birthdayAutomationQueueProvider);
    final verificationQueue = ref.watch(verificationQueueCountProvider);
    final adPerformance = ref.watch(adPerformanceProvider);
    final applicants = ref.watch(marketplaceApplicantsProvider);
    final talents = ref.watch(talentTieringProvider);
    final ads = ref.watch(adSubmissionProvider);

    final centerHealth = ref.watch(centerHealthProvider);
    final adminRoles = ref.watch(localAdminRolesProvider);
    final logs = ref.watch(immutableTransparencyLogProvider);
    final moderatorCodes = ref.watch(moderatorInviteCodeProvider);

    final scheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1117),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F1117),
          title: const Text('GPG Admin Command Center'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Vault'),
              Tab(text: 'Security'),
              Tab(text: 'Finance'),
              Tab(text: 'Ops'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (backendError != null) ...[
                  _card(
                    child: Text(
                      'Backend persistence error: $backendError',
                      style: const TextStyle(color: AppColors.warmCrimson),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _sectionTitle('Global Pulse (Main Overview)'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _miniTitle('Real-Time Geographic Heatmap'),
                      ...onlineHeatmap.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${entry['country']} > ${entry['state']} > ${entry['lga']} · online ${entry['online']}',
                            style: TextStyle(color: scheme.onSurface),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _miniTitle('Registration Velocity'),
                      ...registrationVelocity.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(line, style: TextStyle(color: scheme.onSurface)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _miniTitle('Total Ecosystem Value'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text('Active ${ecosystem['totalActiveUsers']}')),
                          Chip(label: Text('Members ${ecosystem['members']}')),
                          Chip(label: Text('Friends/Seekers ${ecosystem['friendsSeekers']}')),
                          Chip(label: Text('Males ${ecosystem['males']}')),
                          Chip(label: Text('Females ${ecosystem['females']}')),
                          Chip(label: Text('Single ${ecosystem['single']}')),
                          Chip(label: Text('Married ${ecosystem['married']}')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Sector A · The Wholesome Guardrail'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _miniTitle('AI Pulse'),
                      ...aiPulse.take(5).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(item, style: TextStyle(color: scheme.onSurface)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _miniTitle('Heat Map (Friend Sign-ups)'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: heatMap
                            .map(
                              (spot) => Chip(
                                label: Text('${spot['location']} +${spot['spike']}'),
                                backgroundColor: AppColors.pathwayAmber.withValues(alpha: 0.22),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      _miniTitle('Rapid Review (Approve / Deny)'),
                      if (reviewQueue.isEmpty)
                        Text('No pending review items.', style: TextStyle(color: scheme.onSurface))
                      else
                        _rapidReviewDeck(ref, reviewQueue),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Moderator UI Widgets'),
                _card(
                  child: Column(
                    children: const [
                      _WidgetRow('Active Shield', 'Shows Safety Score', 'View 5 pending reports'),
                      _WidgetRow('Talent Desk', 'Shows pending marketplace funds', 'Verify 12 Skill Certificates'),
                      _WidgetRow('Faith Journey', 'Tracks friend-to-member updates', 'Send Welcome Home notifications'),
                      _WidgetRow('Traffic Taiji', 'Shows global latency by region', 'Optimize Node 4'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('1 Billion Users Strategy'),
                _card(
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Level 1: Global AI (Llama 4) filters most toxicity/spam.'),
                      SizedBox(height: 6),
                      Text('Level 2: Local Admins handle local group disputes.'),
                      SizedBox(height: 6),
                      Text('Level 3: GPG Staff handles legal, finance, and ban appeals.'),
                    ],
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle('User Management Vault (Privacy-Compliant)'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _miniTitle('You CAN See'),
                      const Text('Full Name, Age, Phone · LGA/State/Country · Blood Group/Genotype · Mission/Pathway · Payments'),
                      const SizedBox(height: 8),
                      _miniTitle('You CANNOT See'),
                      const Text('Private chat messages · User passwords · Permanently deleted photos · Private prayer/testimony drafts'),
                      const SizedBox(height: 12),
                      _miniTitle('Metadata Records'),
                      ...vaultUsers.map(
                        (u) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${u.fullName} · ${u.age} · ${u.phone} · ${u.lga}, ${u.state} · ${u.missionName} · ${u.pathwayStatus}',
                            style: TextStyle(color: scheme.onSurface),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Advanced Search & Filtering (Powerhouse)'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<AdminQueryPreset>(
                        value: selectedQuery,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: AdminQueryPreset.singleFemalesLagosFinalYear,
                            child: Text('Single Females in Lagos, final year Degree'),
                          ),
                          DropdownMenuItem(
                            value: AdminQueryPreset.returnedMissionariesAbidjan,
                            child: Text('Returned Missionaries from Cote d\'Ivoire Abidjan'),
                          ),
                          DropdownMenuItem(
                            value: AdminQueryPreset.electriciansIkejaAa,
                            child: Text('Certified Electricians in Ikeja with AA genotype'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(selectedAdminQueryPresetProvider.notifier).state = value;
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      if (advancedResults.isEmpty)
                        const Text('No matching results.')
                      else
                        ...advancedResults.map(
                          (u) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '${u.fullName} · ${u.relationshipStatus} · ${u.gender} · ${u.pathwayStatus} · ${u.missionName} · ${u.talent} · ${u.genotype}',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle('Security Shield (AI Moderation Room)'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _miniTitle('Automatic Flagging Desk'),
                      const Text('Flagged scam/un-wholesome posts are frozen and sent to review queue.'),
                      const SizedBox(height: 8),
                      _miniTitle('Genotype Privacy Red Alerts'),
                      ...genotypeAlerts.map(
                        (alert) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(alert, style: const TextStyle(color: AppColors.warmCrimson)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _miniTitle('Shadow Audit Risk List'),
                      ...riskList.map(
                        (risk) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${risk['displayName']} (${risk['userId']}) · ${risk['blocksLast24h']} blocks in 24h',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Break-Glass Review Desk'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.tonal(
                            onPressed: breakGlassDesk.isLoading
                                ? null
                                : () => ref.read(breakGlassDeskControllerProvider.notifier).refresh(),
                            child: const Text('Refresh Alerts'),
                          ),
                        ],
                      ),
                      if (breakGlassDesk.isLoading) ...[
                        const SizedBox(height: 8),
                        const LinearProgressIndicator(),
                      ],
                      if (breakGlassDesk.error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          breakGlassDesk.error!,
                          style: const TextStyle(color: AppColors.warmCrimson),
                        ),
                      ],
                      ...breakGlassDesk.bundles.map(
                        (bundle) => Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chat ${bundle['chatId']} · Risk ${bundle['riskScore'] ?? '-'} · ${bundle['conductCategory']}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text('User History: Reports handled through prior moderation logs.'),
                              const SizedBox(height: 6),
                              Text('Evidence (3–5 messages):', style: TextStyle(color: scheme.onSurface)),
                              ...((bundle['evidenceMessages'] as List<dynamic>? ?? const [])
                                  .take(5)
                                  .map((m) => Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text('• ${(m as Map<String, dynamic>)['body']}'),
                                      ))
                                  .toList()),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton.tonal(
                                    onPressed: () => ref
                                        .read(breakGlassDeskControllerProvider.notifier)
                                        .resolve(bundleId: bundle['id'].toString(), action: 'DISMISSED'),
                                    child: const Text('Dismiss'),
                                  ),
                                  FilledButton.tonal(
                                    onPressed: () => ref
                                        .read(breakGlassDeskControllerProvider.notifier)
                                        .resolve(bundleId: bundle['id'].toString(), action: 'WARNING_SENT'),
                                    child: const Text('Send Warning'),
                                  ),
                                  FilledButton.tonal(
                                    onPressed: () => ref
                                        .read(breakGlassDeskControllerProvider.notifier)
                                        .resolve(bundleId: bundle['id'].toString(), action: 'SUSPENDED_7_DAYS'),
                                    child: const Text('7-Day Suspension'),
                                  ),
                                  FilledButton.tonal(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.warmCrimson.withValues(alpha: 0.24),
                                    ),
                                    onPressed: () => ref
                                        .read(breakGlassDeskControllerProvider.notifier)
                                        .resolve(bundleId: bundle['id'].toString(), action: 'PERMANENT_BAN'),
                                    child: const Text('Permanent Ban'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('User Disciplinary Settings (The Gavel)'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...managedUsers.map(
                        (user) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${user.displayName} (${user.id})'),
                                const SizedBox(height: 4),
                                Text(
                                  'Suspended: ${user.isSuspended} · Shadow: ${user.isShadowBanned} · Ban: ${user.isDeletedBanned}',
                                  style: const TextStyle(color: AppColors.pathwayAmber, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FilledButton.tonal(
                                      onPressed: () => controller.suspendUser(userId: user.id, hours: 24),
                                      child: const Text('Suspend 24h'),
                                    ),
                                    FilledButton.tonal(
                                      onPressed: () => controller.suspendUser(userId: user.id, hours: 7 * 24),
                                      child: const Text('Suspend 7d'),
                                    ),
                                    FilledButton.tonal(
                                      onPressed: () => controller.suspendUser(userId: user.id, hours: 30 * 24),
                                      child: const Text('Suspend 30d'),
                                    ),
                                    FilledButton.tonal(
                                      onPressed: () => controller.shadowBanUser(userId: user.id),
                                      child: const Text('Shadow Ban'),
                                    ),
                                    FilledButton.tonal(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.warmCrimson.withValues(alpha: 0.25),
                                      ),
                                      onPressed: () => controller.deleteBanUser(userId: user.id),
                                      child: const Text('Delete / Ban'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Blacklist size · Phones: ${blacklistedPhones.length}, Devices: ${blacklistedDevices.length}',
                        style: const TextStyle(color: AppColors.pathwayAmber),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle('Financial & Marketplace Control'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _miniTitle('Marketplace Revenue by Category'),
                      ...revenueByCategory.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('${entry['category']}: \$${entry['revenueUsd']}'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _miniTitle('Birthday Automation Queue'),
                      ...birthdayQueue.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('${entry['date']} · ${entry['name']} · ${entry['status']}'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Sector B · Talent Marketplace & Economy'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Tracking: \$${revenue.toStringAsFixed(2)} pending',
                          style: TextStyle(color: scheme.onSurface)),
                      const SizedBox(height: 8),
                      Text('Verification Queue: $verificationQueue skill certificates',
                          style: TextStyle(color: scheme.onSurface)),
                      const SizedBox(height: 12),
                      _miniTitle('Ad Performance'),
                      ...adPerformance.map(
                        (entry) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(entry['ad'].toString(), style: TextStyle(color: scheme.onSurface)),
                          trailing: Text('${entry['clicks']} clicks',
                              style: const TextStyle(color: AppColors.pathwayAmber)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _miniTitle('Gatekeeper Queue'),
                      ...applicants.map(
                        (app) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${app.displayName} · ${app.skillCertificate} · paid=${app.hasPaid}',
                                ),
                              ),
                              FilledButton.tonal(
                                onPressed: () => controller.approveMarketplace(app.id),
                                child: const Text('Approve for Marketplace'),
                              ),
                              const SizedBox(width: 6),
                              FilledButton.tonal(
                                onPressed: () => controller.grantMeritAccess(
                                  applicantId: app.id,
                                  reason: 'Service scholarship / Pathway excellence',
                                ),
                                child: const Text('Grant Merit Access'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _miniTitle('Talent Tiering (GPG Recommended)'),
                      ...talents.map(
                        (talent) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${talent.displayName} · rating ${talent.rating.toStringAsFixed(1)}',
                                ),
                              ),
                              FilledButton.tonal(
                                onPressed: () => controller.featureTalent(talent.id),
                                child: Text(talent.isFeatured ? 'Unfeature' : 'Feature'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Ad Approval Portal (The Standard)'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ads
                        .map(
                          (ad) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${ad.title} · ${ad.creativeType}'),
                                  const SizedBox(height: 4),
                                  Text(ad.copyText),
                                  const SizedBox(height: 4),
                                  Text('Targeting: ${ad.targeting}',
                                      style: const TextStyle(color: AppColors.pathwayAmber)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      FilledButton.tonal(
                                        onPressed: () => controller.moderateAd(adId: ad.id, approved: true),
                                        child: const Text('Approve - Aligns with GPG Values'),
                                      ),
                                      FilledButton.tonal(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.warmCrimson.withValues(alpha: 0.24),
                                        ),
                                        onPressed: () => controller.moderateAd(adId: ad.id, approved: false),
                                        child: const Text('Reject - Inappropriate Content'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle('Control Room Security Flow (RBAC)'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Admin Role Hierarchy'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<AdminRole>(
                        value: activeRole,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: AdminRole.values
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(activeAdminRoleProvider.notifier).state = value;
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text('Active permissions are enforced by role in each action panel.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Sector C · Gathering Place Management'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _miniTitle('Center Health'),
                      ...centerHealth.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${entry['center']} · ${entry['activeGroups']} active groups',
                            style: TextStyle(color: scheme.onSurface),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _miniTitle('Role Management'),
                      ...adminRoles.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${entry['leader']} → ${entry['role']}',
                            style: TextStyle(color: scheme.onSurface),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Moderator Access Code Manager'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Admin generates single-use moderator codes per Gathering Place and role.'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.tonal(
                            onPressed: () {
                              ref.read(moderatorInviteCodeProvider.notifier).generateCode(
                                    gatheringPlace: 'Lagos Island Gathering Place',
                                    role: 'Service Moderator',
                                  );
                            },
                            child: const Text('Generate Lagos Service Mod Code'),
                          ),
                          FilledButton.tonal(
                            onPressed: () {
                              ref.read(moderatorInviteCodeProvider.notifier).generateCode(
                                    gatheringPlace: 'Provo South Gathering Place',
                                    role: 'Temple Prep Moderator',
                                  );
                            },
                            child: const Text('Generate Provo Temple Prep Code'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...moderatorCodes.take(8).map(
                        (code) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '${code.code} · ${code.gatheringPlace} · ${code.role} · ${code.isActive ? 'Active' : 'Used'}',
                            style: TextStyle(color: scheme.onSurface, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Admin Transparency Log'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: logs
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${entry.timestamp} · ${entry.actor} · ${entry.action} · ${entry.target} · ${entry.disciplineStep}',
                              style: TextStyle(color: scheme.onSurface, fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rapidReviewDeck(WidgetRef ref, List<RapidReviewItem> queue) {
    final current = queue.first;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${current.type} · ${current.region}',
              style: const TextStyle(color: AppColors.pathwayAmber, fontSize: 12)),
          const SizedBox(height: 6),
          Text(current.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {
                    final next = [...queue]..removeAt(0);
                    ref.read(rapidReviewQueueProvider.notifier).state = next;
                  },
                  child: const Text('Approve'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {
                    final next = [...queue]..removeAt(0);
                    ref.read(rapidReviewQueueProvider.notifier).state = next;
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warmCrimson.withValues(alpha: 0.24),
                  ),
                  child: const Text('Deny'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.pathwayAmber,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _miniTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.stewardshipGreen,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171A22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: child,
      ),
    );
  }
}

class _WidgetRow extends StatelessWidget {
  const _WidgetRow(this.widgetName, this.function, this.action);

  final String widgetName;
  final String function;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(widgetName, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(flex: 3, child: Text(function)),
          Expanded(
            flex: 3,
            child: Text(action, style: const TextStyle(color: AppColors.pathwayAmber)),
          ),
        ],
      ),
    );
  }
}
