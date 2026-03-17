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

final activeAdminRoleProvider = StateProvider<AdminRole>((ref) => AdminRole.superAdmin);

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
  return const [
    RapidReviewItem(
      id: 'rr1',
      type: 'Marketplace Listing',
      title: 'Certified Electrician · Lekki Axis',
      region: 'Lagos',
    ),
    RapidReviewItem(
      id: 'rr2',
      type: 'Group Post',
      title: 'Pathway Meet-up Promotion',
      region: 'Abuja',
    ),
    RapidReviewItem(
      id: 'rr3',
      type: 'Marketplace Listing',
      title: 'Applied Health Mentor Program',
      region: 'Accra',
    ),
  ];
});

final pendingRevenueUsdProvider = Provider<double>((ref) => 348.0);
final verificationQueueCountProvider = Provider<int>((ref) => 12);
final adPerformanceProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return const [
    {'ad': 'Plumbing Service', 'clicks': 84},
    {'ad': 'Female Tutor (Math)', 'clicks': 62},
    {'ad': 'Graphic Design Mentor', 'clicks': 47},
  ];
});

final centerHealthProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return const [
    {'center': 'Lagos Gathering Place', 'activeGroups': 42},
    {'center': 'Accra Gathering Place', 'activeGroups': 31},
    {'center': 'Nairobi Gathering Place', 'activeGroups': 24},
  ];
});

final localAdminRolesProvider = StateProvider<List<Map<String, String>>>((ref) {
  return const [
    {'leader': 'Stake Admin · Lagos North', 'role': 'Regional Moderator'},
    {'leader': 'District Admin · Accra East', 'role': 'Marketplace Verifier'},
  ];
});

final managedUsersProvider = StateProvider<List<ManagedUser>>((ref) {
  return const [
    ManagedUser(
      id: 'u1001',
      displayName: 'Brother Adam',
      phone: '+2348011111111',
      deviceId: 'device-adam-001',
    ),
    ManagedUser(
      id: 'u1002',
      displayName: 'Sister Ruth',
      phone: '+233241111111',
      deviceId: 'device-ruth-002',
    ),
    ManagedUser(
      id: 'u1003',
      displayName: 'Friend Leo',
      phone: '+819011111111',
      deviceId: 'device-leo-003',
    ),
  ];
});

final marketplaceApplicantsProvider = StateProvider<List<MarketplaceApplicant>>((ref) {
  return const [
    MarketplaceApplicant(
      id: 'mkt1',
      displayName: 'Brother Samuel',
      skillCertificate: 'Electrical Installation L2',
      hasPaid: true,
    ),
    MarketplaceApplicant(
      id: 'mkt2',
      displayName: 'Sister Esther',
      skillCertificate: 'Math Tutor Pathway Badge',
      hasPaid: false,
    ),
  ];
});

final talentTieringProvider = StateProvider<List<TalentTierProfile>>((ref) {
  return const [
    TalentTierProfile(id: 'tt1', displayName: 'Brother Samuel', rating: 4.9),
    TalentTierProfile(id: 'tt2', displayName: 'Sister Esther', rating: 4.8),
    TalentTierProfile(id: 'tt3', displayName: 'Brother Michael', rating: 4.7),
  ];
});

final adSubmissionProvider = StateProvider<List<AdSubmission>>((ref) {
  return const [
    AdSubmission(
      id: 'ad1',
      title: 'Temple Marriage Workshop',
      creativeType: 'Image',
      copyText: 'Prepare spiritually and emotionally for temple marriage.',
      targeting: 'Single Member',
    ),
    AdSubmission(
      id: 'ad2',
      title: 'Applied Health Mentor Circle',
      creativeType: 'Video',
      copyText: 'Join mentors to accelerate your health learning path.',
      targeting: 'Pathway Connect / Degree',
    ),
  ];
});

final blacklistedPhonesProvider = StateProvider<Set<String>>((ref) => <String>{});
final blacklistedDevicesProvider = StateProvider<Set<String>>((ref) => <String>{});
final adminCommandErrorProvider = StateProvider<String?>((ref) => null);

final immutableTransparencyLogProvider = StateProvider<List<ImmutableLogEntry>>((ref) {
  return const [
    ImmutableLogEntry(
      timestamp: '2026-03-17T09:30:12Z',
      actor: 'Local Admin · Lagos North',
      action: 'WARNING_ISSUED',
      target: 'User #u2041',
      disciplineStep: 'Warning',
    ),
    ImmutableLogEntry(
      timestamp: '2026-03-17T10:03:48Z',
      actor: 'GPG Staff · TrustOps',
      action: 'SUSPENSION_APPLIED',
      target: 'User #u1882',
      disciplineStep: 'Suspension',
    ),
    ImmutableLogEntry(
      timestamp: '2026-03-17T10:41:05Z',
      actor: 'Local Admin · Accra East',
      action: 'POST_REMOVED',
      target: 'Post #p9021',
      disciplineStep: 'Policy Action',
    ),
  ];
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
        return permission == 'marketplace_approve' || permission == 'payment_view';
      case AdminRole.serviceMissionaryAdmin:
        return permission == 'mission_peer_groups' || permission == 'birthday_wishes';
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

  Future<void> _withBackendPersistence(Future<void> Function(String adminUserId, dynamic gateway) task) async {
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

    users[index] = users[index].copyWith(isSuspended: true, suspensionHours: hours);
    _ref.read(managedUsersProvider.notifier).state = users;
    _appendLog(actor: role.name, action: 'USER_SUSPENDED', target: users[index].displayName, disciplineStep: 'Suspension ${hours}h');
  }

  Future<void> shadowBanUser({required String userId}) async {
    final role = _ref.read(activeAdminRoleProvider);
    if (!_can(role, 'shadow')) return;

    final users = [..._ref.read(managedUsersProvider)];
    final index = users.indexWhere((u) => u.id == userId);
    if (index == -1) return;

    await _withBackendPersistence((adminUserId, gateway) {
      return gateway.adminShadowBanUser(adminUserId: adminUserId, userId: userId, reason: 'Troll mitigation policy');
    });

    users[index] = users[index].copyWith(isShadowBanned: true);
    _ref.read(managedUsersProvider.notifier).state = users;
    _appendLog(actor: role.name, action: 'USER_SHADOW_BANNED', target: users[index].displayName, disciplineStep: 'Shadow Ban');
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
    _ref.read(blacklistedPhonesProvider.notifier).state = {..._ref.read(blacklistedPhonesProvider), target.phone};
    _ref.read(blacklistedDevicesProvider.notifier).state = {..._ref.read(blacklistedDevicesProvider), target.deviceId};
    _appendLog(actor: role.name, action: 'USER_DELETE_BANNED', target: target.displayName, disciplineStep: 'Permanent Ban');
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
    _appendLog(actor: role.name, action: 'MARKETPLACE_APPROVED', target: list[index].displayName, disciplineStep: 'Marketplace Approval');
  }

  Future<void> grantMeritAccess({required String applicantId, required String reason}) async {
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
    _appendLog(actor: role.name, action: 'MERIT_ACCESS_GRANTED', target: '${list[index].displayName} · Reason: $reason', disciplineStep: 'Merit Add');
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
    _appendLog(actor: role.name, action: nextFeatured ? 'TALENT_FEATURED' : 'TALENT_UNFEATURED', target: list[index].displayName, disciplineStep: 'Talent Tiering');
  }

  Future<void> moderateAd({required String adId, required bool approved}) async {
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

    ads[index] = ads[index].copyWith(status: approved ? AdModerationStatus.approved : AdModerationStatus.rejected);
    _ref.read(adSubmissionProvider.notifier).state = ads;
    _appendLog(actor: role.name, action: approved ? 'AD_APPROVED' : 'AD_REJECTED', target: ads[index].title, disciplineStep: 'Ad Moderation');
  }
}

final adminCommandControllerProvider = Provider<AdminCommandController>((ref) {
  return AdminCommandController(ref);
});
