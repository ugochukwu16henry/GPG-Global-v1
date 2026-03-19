import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backend/providers/backend_live_providers.dart';

enum AdminRole {
  superAdmin,
  moderator,
  financialClerk,
  serviceMissionaryAdmin,
}

enum DisciplinaryAction {
  warning,
  suspension,
  shadowBan,
  deleteBan,
}

enum AdModerationStatus {
  pending,
  approved,
  rejected,
}

class RapidReviewItem {
  const RapidReviewItem({
    required this.id,
    required this.type,
    required this.title,
    required this.region,
  });

  final String id;
  final String type;
  final String title;
  final String region;
}

class ImmutableLogEntry {
  const ImmutableLogEntry({
    required this.timestamp,
    required this.actor,
    required this.action,
    required this.target,
    required this.disciplineStep,
  });

  final String timestamp;
  final String actor;
  final String action;
  final String target;
  final String disciplineStep;
}

class ManagedUser {
  const ManagedUser({
    required this.id,
    required this.displayName,
    this.isSuspended = false,
    this.suspensionHours,
    this.isShadowBanned = false,
    this.isDeletedBanned = false,
    this.deviceId = '',
    this.phone = '',
  });

  final String id;
  final String displayName;
  final bool isSuspended;
  final int? suspensionHours;
  final bool isShadowBanned;
  final bool isDeletedBanned;
  final String deviceId;
  final String phone;

  ManagedUser copyWith({
    bool? isSuspended,
    int? suspensionHours,
    bool? isShadowBanned,
    bool? isDeletedBanned,
  }) {
    return ManagedUser(
      id: id,
      displayName: displayName,
      isSuspended: isSuspended ?? this.isSuspended,
      suspensionHours: suspensionHours ?? this.suspensionHours,
      isShadowBanned: isShadowBanned ?? this.isShadowBanned,
      isDeletedBanned: isDeletedBanned ?? this.isDeletedBanned,
      deviceId: deviceId,
      phone: phone,
    );
  }
}

class MarketplaceApplicant {
  const MarketplaceApplicant({
    required this.id,
    required this.displayName,
    required this.skillCertificate,
    required this.hasPaid,
    this.approved = false,
    this.meritGranted = false,
  });

  final String id;
  final String displayName;
  final String skillCertificate;
  final bool hasPaid;
  final bool approved;
  final bool meritGranted;

  MarketplaceApplicant copyWith({
    bool? approved,
    bool? meritGranted,
  }) {
    return MarketplaceApplicant(
      id: id,
      displayName: displayName,
      skillCertificate: skillCertificate,
      hasPaid: hasPaid,
      approved: approved ?? this.approved,
      meritGranted: meritGranted ?? this.meritGranted,
    );
  }
}

class TalentTierProfile {
  const TalentTierProfile({
    required this.id,
    required this.displayName,
    required this.rating,
    this.isFeatured = false,
  });

  final String id;
  final String displayName;
  final double rating;
  final bool isFeatured;

  TalentTierProfile copyWith({bool? isFeatured}) {
    return TalentTierProfile(
      id: id,
      displayName: displayName,
      rating: rating,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

class AdSubmission {
  const AdSubmission({
    required this.id,
    required this.title,
    required this.creativeType,
    required this.copyText,
    required this.targeting,
    this.status = AdModerationStatus.pending,
  });

  final String id;
  final String title;
  final String creativeType;
  final String copyText;
  final String targeting;
  final AdModerationStatus status;

  AdSubmission copyWith({AdModerationStatus? status}) {
    return AdSubmission(
      id: id,
      title: title,
      creativeType: creativeType,
      copyText: copyText,
      targeting: targeting,
      status: status ?? this.status,
    );
  }
}

final activeAdminRoleProvider =
    StateProvider<AdminRole>((ref) => AdminRole.superAdmin);

final aiPulseFeedProvider = Provider<List<String>>((ref) {
  return const [
    'LOW: Marketplace post flagged for possible misleading pricing',
    'MEDIUM: Group comment flagged for harassment tone',
    'LOW: Profile ad copy flagged for policy review',
  ];
});

final friendSignupHeatmapProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return const [
    {'location': 'Lagos', 'spike': 27},
    {'location': 'Accra', 'spike': 18},
    {'location': 'Salt Lake City', 'spike': 12},
    {'location': 'Tokyo', 'spike': 9},
  ];
});

final rapidReviewQueueProvider = StateProvider<List<RapidReviewItem>>((ref) {
  return const [];
});

final pendingRevenueUsdProvider = Provider<double>((ref) {
  return ref.watch(marketplaceRevenueByCategoryProvider).fold<double>(
      0, (sum, item) => sum + ((item['revenueUsd'] as num?)?.toDouble() ?? 0));
});
final verificationQueueCountProvider = Provider<int>((ref) {
  return ref
      .watch(marketplaceApplicantsProvider)
      .where((a) => !a.approved)
      .length;
});
final adPerformanceProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final ads = ref.watch(adSubmissionProvider);
  return [
    {
      'ad': 'Pending Reviews',
      'clicks': ads.where((a) => a.status == AdModerationStatus.pending).length
    },
    {
      'ad': 'Approved',
      'clicks': ads.where((a) => a.status == AdModerationStatus.approved).length
    },
    {
      'ad': 'Rejected',
      'clicks': ads.where((a) => a.status == AdModerationStatus.rejected).length
    },
  ];
});

final centerHealthProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final heatmap = ref.watch(globalOnlineHeatmapProvider);
  return heatmap
      .take(5)
      .map((entry) => {
            'center': '${entry['state']} Gathering Place',
            'activeGroups': entry['online'],
          })
      .toList(growable: false);
});

final localAdminRolesProvider = StateProvider<List<Map<String, String>>>((ref) {
  final adminUserId = ref.watch(backendUserIdProvider);
  return [
    {'leader': 'Active Admin · $adminUserId', 'role': 'Platform Administrator'},
  ];
});

final managedUsersProvider = StateProvider<List<ManagedUser>>((ref) {
  return const [];
});

final marketplaceApplicantsProvider =
    StateProvider<List<MarketplaceApplicant>>((ref) {
  return const [];
});

final talentTieringProvider = StateProvider<List<TalentTierProfile>>((ref) {
  return const [];
});

final adSubmissionProvider = StateProvider<List<AdSubmission>>((ref) {
  return const [];
});

final blacklistedPhonesProvider =
    StateProvider<Set<String>>((ref) => <String>{});
final blacklistedDevicesProvider =
    StateProvider<Set<String>>((ref) => <String>{});
final adminCommandErrorProvider = StateProvider<String?>((ref) => null);

final immutableTransparencyLogProvider =
    StateProvider<List<ImmutableLogEntry>>((ref) {
  return const [];
});

final mergedAiPulseProvider = Provider<List<String>>((ref) {
  final local = ref.watch(aiPulseFeedProvider);
  final redFlag = ref.watch(backendRedFlagStreamProvider);

  return redFlag.when(
    data: (value) => [value, ...local],
    loading: () => local,
    error: (_, __) => local,
  );
});

enum AdminQueryPreset {
  singleFemalesLagosFinalYear,
  returnedMissionariesAbidjan,
  electriciansIkejaAa,
}

class VaultUserMetadata {
  const VaultUserMetadata({
    required this.id,
    required this.fullName,
    required this.age,
    required this.phone,
    required this.country,
    required this.state,
    required this.lga,
    required this.memberType,
    required this.gender,
    required this.relationshipStatus,
    required this.pathwayStatus,
    required this.academicYear,
    required this.missionName,
    required this.talent,
    required this.bloodGroup,
    required this.genotype,
  });

  final String id;
  final String fullName;
  final int age;
  final String phone;
  final String country;
  final String state;
  final String lga;
  final String memberType;
  final String gender;
  final String relationshipStatus;
  final String pathwayStatus;
  final String academicYear;
  final String missionName;
  final String talent;
  final String bloodGroup;
  final String genotype;
}

final registrationVelocityProvider = Provider<List<String>>((ref) {
  final total = ref.watch(vaultUsersProvider).length;
  return [
    '$total total profiles loaded from backend',
    '${ref.watch(marketplaceApplicantsProvider).length} marketplace applications in queue',
    '${ref.watch(breakGlassDeskControllerProvider).bundles.length} break-glass safety cases',
  ];
});

final globalOnlineHeatmapProvider = Provider<List<Map<String, Object>>>((ref) {
  final users = ref.watch(vaultUsersProvider);
  final grouped = <String, int>{};
  for (final user in users) {
    final key = '${user.country}|${user.state}|${user.lga}';
    grouped[key] = (grouped[key] ?? 0) + 1;
  }
  final rows = grouped.entries.map((entry) {
    final parts = entry.key.split('|');
    return {
      'country': parts[0],
      'state': parts[1],
      'lga': parts[2],
      'online': entry.value,
    };
  }).toList(growable: false)
    ..sort((a, b) => (b['online'] as int).compareTo(a['online'] as int));
  return rows;
});

final ecosystemValueProvider = Provider<Map<String, int>>((ref) {
  final users = ref.watch(vaultUsersProvider);
  final total = users.length;
  final females = users.where((u) => u.gender.toLowerCase() == 'female').length;
  final males = users.where((u) => u.gender.toLowerCase() == 'male').length;
  final single =
      users.where((u) => u.relationshipStatus.toLowerCase() == 'single').length;
  final married = users
      .where((u) => u.relationshipStatus.toLowerCase() == 'married')
      .length;
  final members =
      users.where((u) => u.memberType.toLowerCase() == 'member').length;
  return {
    'totalActiveUsers': total,
    'members': members,
    'friendsSeekers': total - members,
    'males': males,
    'females': females,
    'single': single,
    'married': married,
  };
});

final vaultUsersProvider =
    StateProvider<List<VaultUserMetadata>>((ref) => const []);

final selectedAdminQueryPresetProvider = StateProvider<AdminQueryPreset>(
    (ref) => AdminQueryPreset.singleFemalesLagosFinalYear);

final advancedSearchResultsProvider = Provider<List<VaultUserMetadata>>((ref) {
  final users = ref.watch(vaultUsersProvider);
  final preset = ref.watch(selectedAdminQueryPresetProvider);
  switch (preset) {
    case AdminQueryPreset.singleFemalesLagosFinalYear:
      return users
          .where((u) =>
              u.relationshipStatus == 'Single' &&
              u.gender == 'Female' &&
              u.state == 'Lagos' &&
              u.pathwayStatus == 'Degree' &&
              u.academicYear == 'Final Year')
          .toList(growable: false);
    case AdminQueryPreset.returnedMissionariesAbidjan:
      return users
          .where((u) =>
              u.missionName == 'Cote d\'Ivoire Abidjan Mission' &&
              u.pathwayStatus == 'Alumni')
          .toList(growable: false);
    case AdminQueryPreset.electriciansIkejaAa:
      return users
          .where((u) =>
              u.talent == 'Electrician' &&
              u.lga == 'Ikeja' &&
              u.genotype == 'AA')
          .toList(growable: false);
  }
});

final genotypePrivacyAlertsProvider = Provider<List<String>>((ref) {
  final bundles = ref.watch(breakGlassDeskControllerProvider).bundles;
  if (bundles.isEmpty) {
    return const [];
  }
  return bundles
      .take(3)
      .map((bundle) =>
          'Privacy alert on user ${bundle['reportedUserId']} · ${bundle['conductCategory']}')
      .toList(growable: false);
});

final highBlockRiskListProvider = Provider<List<Map<String, Object>>>((ref) {
  final bundles = ref.watch(breakGlassDeskControllerProvider).bundles;
  final counts = <String, int>{};
  for (final bundle in bundles) {
    final userId = (bundle['reportedUserId'] ?? '').toString();
    if (userId.isEmpty) continue;
    counts[userId] = (counts[userId] ?? 0) + 1;
  }
  final usersById = {
    for (final u in ref.watch(managedUsersProvider)) u.id: u.displayName,
  };
  final list = counts.entries
      .map((entry) => {
            'userId': entry.key,
            'displayName': usersById[entry.key] ?? 'User ${entry.key}',
            'blocksLast24h': entry.value,
          })
      .toList(growable: false)
    ..sort((a, b) =>
        (b['blocksLast24h'] as int).compareTo(a['blocksLast24h'] as int));
  return list;
});

final marketplaceRevenueByCategoryProvider =
    Provider<List<Map<String, Object>>>((ref) {
  final talents = ref.watch(talentTieringProvider);
  if (talents.isEmpty) return const [];
  return [
    {'category': 'Talent Listings', 'revenueUsd': talents.length * 10},
  ];
});

final birthdayAutomationQueueProvider =
    Provider<List<Map<String, String>>>((ref) {
  return const [];
});

class AdminCommandController {
  AdminCommandController(this._ref);

  final Ref _ref;

  bool _can(AdminRole role, String permission) {
    switch (role) {
      case AdminRole.superAdmin:
        return true;
      case AdminRole.moderator:
        return permission == 'suspend' ||
            permission == 'shadow' ||
            permission == 'marketplace_approve' ||
            permission == 'ad_review';
      case AdminRole.financialClerk:
        return permission == 'marketplace_approve' ||
            permission == 'payment_view';
      case AdminRole.serviceMissionaryAdmin:
        return permission == 'mission_peer_groups' ||
            permission == 'birthday_wishes';
    }
  }

  Future<void> _syncLogsFromBackend() async {
    try {
      final gateway = _ref.read(backendGatewayProvider);
      final rows = await gateway.adminActionLogs(limit: 50);
      final mapped = rows
          .map(
            (row) => ImmutableLogEntry(
              timestamp: (row['createdAt'] ?? '').toString(),
              actor: 'Admin ${row['adminUserId']}',
              action: (row['action'] ?? '').toString(),
              target: (row['targetEntity'] ?? '').toString(),
              disciplineStep: (row['reason'] ?? 'System Action').toString(),
            ),
          )
          .toList(growable: false);
      _ref.read(immutableTransparencyLogProvider.notifier).state = mapped;
    } catch (_) {
      // Keep local log as fallback
    }
  }

  Future<void> bootstrapDashboard() async {
    final gateway = _ref.read(backendGatewayProvider);
    try {
      _ref.read(adminCommandErrorProvider.notifier).state = null;

      final users = await gateway.communitySearch();
      final disciplineRows = await gateway.userDisciplineStates(limit: 200);
      final approvalRows = await gateway.marketplaceApprovals(limit: 200);
      final talentRows = await gateway.talentFeatures(limit: 200);
      final adRows = await gateway.adModerationReviews(limit: 200);
      final bannedRows = await gateway.bannedIdentities(limit: 200);

      final disciplineByUser = {
        for (final row in disciplineRows) (row['userId'] ?? '').toString(): row,
      };

      final vault = users
          .map(
            (user) => VaultUserMetadata(
              id: (user['id'] ?? '').toString(),
              fullName: (user['displayName'] ?? 'Unknown').toString(),
              age: 0,
              phone: 'Hidden',
              country: 'Unknown',
              state: (user['state'] ?? 'Unknown').toString(),
              lga: (user['lga'] ?? 'Unknown').toString(),
              memberType: 'Unknown',
              gender: (user['gender'] ?? 'Unknown').toString(),
              relationshipStatus:
                  (user['relationshipStatus'] ?? 'Unknown').toString(),
              pathwayStatus: 'Unknown',
              academicYear: 'Unknown',
              missionName:
                  ((user['mission'] as Map<String, dynamic>?)?['missionName'] ??
                          'Unknown')
                      .toString(),
              talent: (user['academicFocus'] ?? 'Unknown').toString(),
              bloodGroup: 'Restricted',
              genotype: 'Restricted',
            ),
          )
          .toList(growable: false);

      final userNameById = {
        for (final user in users)
          (user['id'] ?? '').toString():
              (user['displayName'] ?? 'Unknown').toString(),
      };

      final managed = users.map(
        (user) {
          final userId = (user['id'] ?? '').toString();
          final discipline =
              disciplineByUser[userId] ?? const <String, dynamic>{};
          return ManagedUser(
            id: userId,
            displayName: (user['displayName'] ?? 'Unknown').toString(),
            phone: '',
            deviceId: '',
            isSuspended:
                (discipline['suspendedUntil'] ?? '').toString().isNotEmpty,
            isShadowBanned: discipline['isShadowBanned'] == true,
            isDeletedBanned: discipline['isDeletedBanned'] == true,
          );
        },
      ).toList(growable: false);

      final talents = talentRows
          .map(
            (row) => TalentTierProfile(
              id: (row['userId'] ?? '').toString(),
              displayName:
                  userNameById[(row['userId'] ?? '').toString()] ?? 'Unknown',
              rating: 4.0,
              isFeatured: row['isFeatured'] == true,
            ),
          )
          .toList(growable: false);

      final applicants = approvalRows
          .map(
            (row) => MarketplaceApplicant(
              id: (row['userId'] ?? '').toString(),
              displayName:
                  userNameById[(row['userId'] ?? '').toString()] ?? 'Unknown',
              skillCertificate:
                  (row['certificateTitle'] ?? 'Unknown Certificate').toString(),
              hasPaid: true,
              approved: (row['status'] ?? '').toString() == 'APPROVED' ||
                  (row['status'] ?? '').toString() == 'MERIT_GRANTED',
              meritGranted: (row['status'] ?? '').toString() == 'MERIT_GRANTED',
            ),
          )
          .toList(growable: false);

      final ads = adRows
          .map(
            (row) => AdSubmission(
              id: (row['externalAdId'] ?? '').toString(),
              title: 'Ad ${(row['externalAdId'] ?? '').toString()}',
              creativeType: 'Unknown',
              copyText: (row['note'] ?? 'No ad copy provided').toString(),
              targeting: (row['targeting'] ?? 'General').toString(),
              status: (row['status'] ?? '').toString() == 'APPROVED'
                  ? AdModerationStatus.approved
                  : (row['status'] ?? '').toString() == 'REJECTED'
                      ? AdModerationStatus.rejected
                      : AdModerationStatus.pending,
            ),
          )
          .toList(growable: false);

      _ref.read(vaultUsersProvider.notifier).state = vault;
      _ref.read(managedUsersProvider.notifier).state = managed;
      _ref.read(talentTieringProvider.notifier).state = talents;
      _ref.read(marketplaceApplicantsProvider.notifier).state = applicants;
      _ref.read(adSubmissionProvider.notifier).state = ads;

      _ref.read(blacklistedPhonesProvider.notifier).state = bannedRows
          .map((row) => (row['phone'] ?? '').toString())
          .where((value) => value.isNotEmpty)
          .toSet();
      _ref.read(blacklistedDevicesProvider.notifier).state = bannedRows
          .map((row) => (row['deviceId'] ?? '').toString())
          .where((value) => value.isNotEmpty)
          .toSet();

      final breakGlass = _ref.read(breakGlassDeskControllerProvider.notifier);
      await breakGlass.refresh();
      final bundles = _ref.read(breakGlassDeskControllerProvider).bundles;
      _ref.read(rapidReviewQueueProvider.notifier).state = bundles
          .take(10)
          .map(
            (bundle) => RapidReviewItem(
              id: (bundle['id'] ?? '').toString(),
              type: 'Safety Bundle',
              title: (bundle['conductCategory'] ?? 'Policy Review').toString(),
              region: ((bundle['chatId'] ?? 'Global')).toString(),
            ),
          )
          .toList(growable: false);

      await _syncLogsFromBackend();
      await _ref.read(moderatorInviteCodeBackendProvider.notifier).refresh();
    } catch (error) {
      _ref.read(adminCommandErrorProvider.notifier).state = error.toString();
    }
  }

  Future<void> _withBackendPersistence(
      Future<void> Function(String adminUserId, dynamic gateway) task) async {
    final gateway = _ref.read(backendGatewayProvider);
    final adminUserId = _ref.read(backendUserIdProvider);
    try {
      _ref.read(adminCommandErrorProvider.notifier).state = null;
      await task(adminUserId, gateway);
      await _syncLogsFromBackend();
    } catch (error) {
      _ref.read(adminCommandErrorProvider.notifier).state = error.toString();
      rethrow;
    }
  }

  void _appendLog({
    required String actor,
    required String action,
    required String target,
    required String disciplineStep,
  }) {
    final list = [..._ref.read(immutableTransparencyLogProvider)];
    list.insert(
      0,
      ImmutableLogEntry(
        timestamp: DateTime.now().toUtc().toIso8601String(),
        actor: actor,
        action: action,
        target: target,
        disciplineStep: disciplineStep,
      ),
    );
    _ref.read(immutableTransparencyLogProvider.notifier).state = list;
  }

  Future<void> suspendUser({required String userId, required int hours}) async {
    final role = _ref.read(activeAdminRoleProvider);
    if (!_can(role, 'suspend')) return;

    final users = [..._ref.read(managedUsersProvider)];
    final index = users.indexWhere((u) => u.id == userId);
    if (index == -1) return;

    await _withBackendPersistence((adminUserId, gateway) {
      return gateway.adminSuspendUser(
        adminUserId: adminUserId,
        userId: userId,
        hours: hours,
        reason: 'Wholesome policy timeout',
      );
    });

    users[index] =
        users[index].copyWith(isSuspended: true, suspensionHours: hours);
    _ref.read(managedUsersProvider.notifier).state = users;
    _appendLog(
        actor: role.name,
        action: 'USER_SUSPENDED',
        target: users[index].displayName,
        disciplineStep: 'Suspension ${hours}h');
  }

  Future<void> shadowBanUser({required String userId}) async {
    final role = _ref.read(activeAdminRoleProvider);
    if (!_can(role, 'shadow')) return;

    final users = [..._ref.read(managedUsersProvider)];
    final index = users.indexWhere((u) => u.id == userId);
    if (index == -1) return;

    await _withBackendPersistence((adminUserId, gateway) {
      return gateway.adminShadowBanUser(
          adminUserId: adminUserId,
          userId: userId,
          reason: 'Troll mitigation policy');
    });

    users[index] = users[index].copyWith(isShadowBanned: true);
    _ref.read(managedUsersProvider.notifier).state = users;
    _appendLog(
        actor: role.name,
        action: 'USER_SHADOW_BANNED',
        target: users[index].displayName,
        disciplineStep: 'Shadow Ban');
  }

  Future<void> deleteBanUser({required String userId}) async {
    final role = _ref.read(activeAdminRoleProvider);
    if (role != AdminRole.superAdmin) return;

    final users = [..._ref.read(managedUsersProvider)];
    final index = users.indexWhere((u) => u.id == userId);
    if (index == -1) return;
    final target = users[index];

    await _withBackendPersistence((adminUserId, gateway) {
      return gateway.adminDeleteBanUser(
        adminUserId: adminUserId,
        userId: userId,
        phone: target.phone,
        deviceId: target.deviceId,
        reason: 'Permanent ban enforced',
      );
    });

    users[index] = users[index].copyWith(isDeletedBanned: true);
    _ref.read(managedUsersProvider.notifier).state = users;
    _ref.read(blacklistedPhonesProvider.notifier).state = {
      ..._ref.read(blacklistedPhonesProvider),
      target.phone
    };
    _ref.read(blacklistedDevicesProvider.notifier).state = {
      ..._ref.read(blacklistedDevicesProvider),
      target.deviceId
    };
    _appendLog(
        actor: role.name,
        action: 'USER_DELETE_BANNED',
        target: target.displayName,
        disciplineStep: 'Permanent Ban');
  }

  Future<void> approveMarketplace(String applicantId) async {
    final role = _ref.read(activeAdminRoleProvider);
    if (!_can(role, 'marketplace_approve')) return;

    final list = [..._ref.read(marketplaceApplicantsProvider)];
    final index = list.indexWhere((a) => a.id == applicantId);
    if (index == -1) return;

    await _withBackendPersistence((adminUserId, gateway) {
      return gateway.adminApproveMarketplace(
        adminUserId: adminUserId,
        userId: list[index].id,
        certificateTitle: list[index].skillCertificate,
      );
    });

    list[index] = list[index].copyWith(approved: true);
    _ref.read(marketplaceApplicantsProvider.notifier).state = list;
    _appendLog(
        actor: role.name,
        action: 'MARKETPLACE_APPROVED',
        target: list[index].displayName,
        disciplineStep: 'Marketplace Approval');
  }

  Future<void> grantMeritAccess(
      {required String applicantId, required String reason}) async {
    final role = _ref.read(activeAdminRoleProvider);
    if (role != AdminRole.superAdmin && role != AdminRole.moderator) return;

    final list = [..._ref.read(marketplaceApplicantsProvider)];
    final index = list.indexWhere((a) => a.id == applicantId);
    if (index == -1) return;

    await _withBackendPersistence((adminUserId, gateway) {
      return gateway.adminGrantMeritMarketplace(
        adminUserId: adminUserId,
        userId: list[index].id,
        certificateTitle: list[index].skillCertificate,
        reason: reason,
      );
    });

    list[index] = list[index].copyWith(approved: true, meritGranted: true);
    _ref.read(marketplaceApplicantsProvider.notifier).state = list;
    _appendLog(
        actor: role.name,
        action: 'MERIT_ACCESS_GRANTED',
        target: '${list[index].displayName} · Reason: $reason',
        disciplineStep: 'Merit Add');
  }

  Future<void> featureTalent(String talentId) async {
    final role = _ref.read(activeAdminRoleProvider);
    if (role == AdminRole.serviceMissionaryAdmin) return;

    final list = [..._ref.read(talentTieringProvider)];
    final index = list.indexWhere((t) => t.id == talentId);
    if (index == -1) return;

    final nextFeatured = !list[index].isFeatured;
    await _withBackendPersistence((adminUserId, gateway) {
      return gateway.adminSetTalentFeatured(
        adminUserId: adminUserId,
        userId: list[index].id,
        isFeatured: nextFeatured,
      );
    });

    list[index] = list[index].copyWith(isFeatured: nextFeatured);
    _ref.read(talentTieringProvider.notifier).state = list;
    _appendLog(
        actor: role.name,
        action: nextFeatured ? 'TALENT_FEATURED' : 'TALENT_UNFEATURED',
        target: list[index].displayName,
        disciplineStep: 'Talent Tiering');
  }

  Future<void> moderateAd(
      {required String adId, required bool approved}) async {
    final role = _ref.read(activeAdminRoleProvider);
    if (!_can(role, 'ad_review')) return;

    final ads = [..._ref.read(adSubmissionProvider)];
    final index = ads.indexWhere((a) => a.id == adId);
    if (index == -1) return;

    await _withBackendPersistence((adminUserId, gateway) {
      return gateway.adminReviewAd(
        adminUserId: adminUserId,
        adId: adId,
        targeting: ads[index].targeting,
        approved: approved,
        note: approved ? 'Aligns with GPG values' : 'Rejected by policy review',
      );
    });

    ads[index] = ads[index].copyWith(
        status: approved
            ? AdModerationStatus.approved
            : AdModerationStatus.rejected);
    _ref.read(adSubmissionProvider.notifier).state = ads;
    _appendLog(
        actor: role.name,
        action: approved ? 'AD_APPROVED' : 'AD_REJECTED',
        target: ads[index].title,
        disciplineStep: 'Ad Moderation');
  }
}

final adminCommandControllerProvider = Provider<AdminCommandController>((ref) {
  return AdminCommandController(ref);
});
