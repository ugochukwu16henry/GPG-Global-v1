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

final marketplaceApplicantsProvider =
    StateProvider<List<MarketplaceApplicant>>((ref) {
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

final blacklistedPhonesProvider =
    StateProvider<Set<String>>((ref) => <String>{});
final blacklistedDevicesProvider =
    StateProvider<Set<String>>((ref) => <String>{});
final adminCommandErrorProvider = StateProvider<String?>((ref) => null);

final immutableTransparencyLogProvider =
    StateProvider<List<ImmutableLogEntry>>((ref) {
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
  return const [
    '14 new Friends joined in Accra',
    '5 Members updated to BYU-Pathway Degree in Nairobi',
    '9 Friend signups this hour in Benin City',
  ];
});

final globalOnlineHeatmapProvider = Provider<List<Map<String, Object>>>((ref) {
  return const [
    {'country': 'Nigeria', 'state': 'Lagos', 'lga': 'Ikeja', 'online': 182},
    {
      'country': 'Ghana',
      'state': 'Greater Accra',
      'lga': 'Accra Metro',
      'online': 126
    },
    {'country': 'Kenya', 'state': 'Nairobi', 'lga': 'Westlands', 'online': 74},
    {'country': 'USA', 'state': 'Utah', 'lga': 'Salt Lake City', 'online': 63},
  ];
});

final ecosystemValueProvider = Provider<Map<String, int>>((ref) {
  return const {
    'totalActiveUsers': 15420,
    'members': 8421,
    'friendsSeekers': 6999,
    'males': 7240,
    'females': 8180,
    'single': 10304,
    'married': 5116,
  };
});

final vaultUsersProvider = Provider<List<VaultUserMetadata>>((ref) {
  return const [
    VaultUserMetadata(
      id: 'u3001',
      fullName: 'Sister Ada Okafor',
      age: 24,
      phone: '+2348012340001',
      country: 'Nigeria',
      state: 'Lagos',
      lga: 'Ikeja',
      memberType: 'Member',
      gender: 'Female',
      relationshipStatus: 'Single',
      pathwayStatus: 'Degree',
      academicYear: 'Final Year',
      missionName: 'Nigeria Lagos Mission',
      talent: 'Electrician',
      bloodGroup: 'A+',
      genotype: 'AA',
    ),
    VaultUserMetadata(
      id: 'u3002',
      fullName: 'Brother Kofi Mensah',
      age: 27,
      phone: '+233241220011',
      country: 'Ghana',
      state: 'Greater Accra',
      lga: 'Accra Metro',
      memberType: 'Member',
      gender: 'Male',
      relationshipStatus: 'Single',
      pathwayStatus: 'Alumni',
      academicYear: 'Graduated',
      missionName: 'Cote d\'Ivoire Abidjan Mission',
      talent: 'Teacher',
      bloodGroup: 'O+',
      genotype: 'AS',
    ),
    VaultUserMetadata(
      id: 'u3003',
      fullName: 'Brother Daniel Aina',
      age: 29,
      phone: '+2348099900011',
      country: 'Nigeria',
      state: 'Lagos',
      lga: 'Ikeja',
      memberType: 'Friend/Seeker',
      gender: 'Male',
      relationshipStatus: 'Married',
      pathwayStatus: 'Connect',
      academicYear: 'Year 1',
      missionName: 'Nigeria Benin Mission',
      talent: 'Electrician',
      bloodGroup: 'B+',
      genotype: 'AA',
    ),
  ];
});

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
  return const [
    'Red Alert: Unauthorized genotype access attempt blocked for user u3001',
    'Red Alert: Sensitive data query from unverified role denied in Lagos cluster',
  ];
});

final highBlockRiskListProvider = Provider<List<Map<String, Object>>>((ref) {
  return const [
    {'userId': 'u1003', 'displayName': 'Friend Leo', 'blocksLast24h': 53},
    {
      'userId': 'u2188',
      'displayName': 'Unknown Seeker Account',
      'blocksLast24h': 31
    },
  ];
});

final marketplaceRevenueByCategoryProvider =
    Provider<List<Map<String, Object>>>((ref) {
  return const [
    {'category': 'Electricians', 'revenueUsd': 1240},
    {'category': 'Teachers', 'revenueUsd': 940},
    {'category': 'Designers', 'revenueUsd': 610},
  ];
});

final birthdayAutomationQueueProvider =
    Provider<List<Map<String, String>>>((ref) {
  return const [
    {
      'date': '2026-03-18',
      'name': 'Sister Mercy',
      'status': 'Authorized Wish Scheduled'
    },
    {'date': '2026-03-19', 'name': 'Brother Adam', 'status': 'Queued'},
    {'date': '2026-03-20', 'name': 'Sister Ruth', 'status': 'Queued'},
  ];
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
