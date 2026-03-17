import 'dart:convert';

import 'package:http/http.dart' as http;

class BackendGateway {
  BackendGateway({
    required this.baseUrl,
    required this.userId,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final String userId;
  final http.Client _client;

  Uri get _graphqlUri => Uri.parse('$baseUrl/graphql');

  Future<Map<String, dynamic>> _query(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    final response = await _client.post(
      _graphqlUri,
      headers: {
        'content-type': 'application/json',
        'x-user-id': userId,
      },
      body: jsonEncode({
        'query': query,
        'variables': variables ?? <String, dynamic>{},
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('Backend request failed (${response.statusCode}).');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    if (payload['errors'] != null) {
      final errors = payload['errors'] as List<dynamic>;
      throw Exception('GraphQL error: ${errors.first['message']}');
    }

    return payload['data'] as Map<String, dynamic>;
  }

  Future<List<String>> suggestMissions(String queryText) async {
    final data = await _query(
      '''
      query SuggestMissions(
        ${r'$'}query: String!
      ) {
        suggestMissions(query: ${r'$'}query) {
          missionName
        }
      }
      ''',
      variables: {'query': queryText},
    );

    final items = data['suggestMissions'] as List<dynamic>;
    return items
        .map((item) => (item as Map<String, dynamic>)['missionName'] as String)
        .toList(growable: false);
  }

  Future<String> missionPeerMatchSummary(String missionId) async {
    final data = await _query(
      '''
      query MissionPeerMatch(
        ${r'$'}missionId: String!
      ) {
        missionPeerMatch(missionId: ${r'$'}missionId) {
          summary
        }
      }
      ''',
      variables: {'missionId': missionId},
    );

    final result = data['missionPeerMatch'] as Map<String, dynamic>;
    return result['summary'] as String;
  }

  Future<String?> createMarketplaceCheckout(String userId) async {
    final data = await _query(
      '''
      mutation CreateMarketplaceCheckout(
        ${r'$'}userId: ID!
      ) {
        createMarketplaceCheckout(userId: ${r'$'}userId) {
          checkoutUrl
        }
      }
      ''',
      variables: {'userId': userId},
    );

    final result = data['createMarketplaceCheckout'] as Map<String, dynamic>;
    return result['checkoutUrl'] as String?;
  }

  Future<String?> sendChatForModeration({
    required String senderUserId,
    required String roomId,
    required String body,
  }) async {
    final data = await _query(
      '''
      mutation SendChatMessage(
        ${r'$'}senderUserId: ID!,
        ${r'$'}roomId: String!,
        ${r'$'}body: String!
      ) {
        sendChatMessage(senderUserId: ${r'$'}senderUserId, roomId: ${r'$'}roomId, body: ${r'$'}body) {
          messageId
          redFlag {
            reason
            severity
          }
        }
      }
      ''',
      variables: {
        'senderUserId': senderUserId,
        'roomId': roomId,
        'body': body,
      },
    );

    final result = data['sendChatMessage'] as Map<String, dynamic>;
    final redFlag = result['redFlag'] as Map<String, dynamic>?;
    if (redFlag == null) {
      return null;
    }
    return '${redFlag['severity']}: ${redFlag['reason']}';
  }

  Future<void> setUserProfile({
    required String userId,
    required String displayName,
    required bool isMember,
    required String missionId,
    required bool servedMission,
    required String pathwayStatus,
    required bool isPathwayConnect,
    required bool isDegree,
    required bool isAlumni,
    required String academicFocus,
    required String country,
    required String state,
    required String lga,
    required String relationshipStatus,
    required String gender,
    bool? allowsBirthdayBroadcast,
    bool? safeSearchFemaleOnly,
    bool? safeSearchVerifiedMembersOnly,
  }) async {
    await _query(
      '''
      mutation SetUserProfile(
        ${r'$'}userId: ID!,
        ${r'$'}displayName: String,
        ${r'$'}isMember: Boolean,
        ${r'$'}missionId: ID,
        ${r'$'}servedMission: Boolean,
        ${r'$'}pathwayStatus: PathwayStatus,
        ${r'$'}isPathwayConnect: Boolean,
        ${r'$'}isDegree: Boolean,
        ${r'$'}isAlumni: Boolean,
        ${r'$'}academicFocus: String,
        ${r'$'}country: String,
        ${r'$'}state: String,
        ${r'$'}lga: String,
        ${r'$'}relationshipStatus: RelationshipStatus,
        ${r'$'}gender: Gender,
        ${r'$'}allowsBirthdayBroadcast: Boolean,
        ${r'$'}safeSearchFemaleOnly: Boolean,
        ${r'$'}safeSearchVerifiedMembersOnly: Boolean
      ) {
        setUserProfile(
          userId: ${r'$'}userId,
          displayName: ${r'$'}displayName,
          isMember: ${r'$'}isMember,
          missionId: ${r'$'}missionId,
          servedMission: ${r'$'}servedMission,
          pathwayStatus: ${r'$'}pathwayStatus,
          isPathwayConnect: ${r'$'}isPathwayConnect,
          isDegree: ${r'$'}isDegree,
          isAlumni: ${r'$'}isAlumni,
          academicFocus: ${r'$'}academicFocus,
          country: ${r'$'}country,
          state: ${r'$'}state,
          lga: ${r'$'}lga,
          relationshipStatus: ${r'$'}relationshipStatus,
          gender: ${r'$'}gender,
          allowsBirthdayBroadcast: ${r'$'}allowsBirthdayBroadcast,
          safeSearchFemaleOnly: ${r'$'}safeSearchFemaleOnly,
          safeSearchVerifiedMembersOnly: ${r'$'}safeSearchVerifiedMembersOnly
        ) {
          id
        }
      }
      ''',
      variables: {
        'userId': userId,
        'displayName': displayName,
        'isMember': isMember,
        'missionId': missionId,
        'servedMission': servedMission,
        'pathwayStatus': pathwayStatus,
        'isPathwayConnect': isPathwayConnect,
        'isDegree': isDegree,
        'isAlumni': isAlumni,
        'academicFocus': academicFocus,
        'country': country,
        'state': state,
        'lga': lga,
        'relationshipStatus': relationshipStatus,
        'gender': gender,
        'allowsBirthdayBroadcast': allowsBirthdayBroadcast,
        'safeSearchFemaleOnly': safeSearchFemaleOnly,
        'safeSearchVerifiedMembersOnly': safeSearchVerifiedMembersOnly,
      },
    );
  }

  Future<void> setFieldVisibility({
    required String userId,
    required String fieldKey,
    required String visibility,
  }) async {
    await _query(
      '''
      mutation SetFieldVisibility(
        ${r'$'}userId: ID!,
        ${r'$'}fieldKey: String!,
        ${r'$'}visibility: VisibilityLevel!
      ) {
        setFieldVisibility(
          userId: ${r'$'}userId,
          fieldKey: ${r'$'}fieldKey,
          visibility: ${r'$'}visibility
        )
      }
      ''',
      variables: {
        'userId': userId,
        'fieldKey': fieldKey,
        'visibility': visibility,
      },
    );
  }

  Future<void> setSafetyMode({
    required String userId,
    required bool femaleOnly,
    required bool verifiedMembersOnly,
  }) async {
    await _query(
      '''
      mutation SetSafetyMode(
        ${r'$'}userId: ID!,
        ${r'$'}femaleOnly: Boolean!,
        ${r'$'}verifiedMembersOnly: Boolean!
      ) {
        setSafetyMode(
          userId: ${r'$'}userId,
          femaleOnly: ${r'$'}femaleOnly,
          verifiedMembersOnly: ${r'$'}verifiedMembersOnly
        )
      }
      ''',
      variables: {
        'userId': userId,
        'femaleOnly': femaleOnly,
        'verifiedMembersOnly': verifiedMembersOnly,
      },
    );
  }

  Future<String?> sendPhoneOtp(String phone) async {
    final data = await _query(
      '''
      mutation SendPhoneOtp(
        ${r'$'}phone: String!
      ) {
        sendPhoneOtp(phone: ${r'$'}phone) {
          devOtpPreview
        }
      }
      ''',
      variables: {
        'phone': phone,
      },
    );

    final result = data['sendPhoneOtp'] as Map<String, dynamic>;
    return result['devOtpPreview'] as String?;
  }

  Future<String> verifyPhoneOtp({
    required String phone,
    required String otpCode,
  }) async {
    final data = await _query(
      '''
      mutation VerifyPhoneOtp(
        ${r'$'}phone: String!,
        ${r'$'}otpCode: String!
      ) {
        verifyPhoneOtp(phone: ${r'$'}phone, otpCode: ${r'$'}otpCode) {
          id
        }
      }
      ''',
      variables: {
        'phone': phone,
        'otpCode': otpCode,
      },
    );

    final result = data['verifyPhoneOtp'] as Map<String, dynamic>;
    return result['id'] as String;
  }

  Future<void> adminSuspendUser({
    required String adminUserId,
    required String userId,
    required int hours,
    String? reason,
  }) async {
    await _query(
      '''
      mutation AdminSuspendUser(
        ${r'$'}adminUserId: ID!,
        ${r'$'}userId: ID!,
        ${r'$'}hours: Int!,
        ${r'$'}reason: String
      ) {
        adminSuspendUser(adminUserId: ${r'$'}adminUserId, userId: ${r'$'}userId, hours: ${r'$'}hours, reason: ${r'$'}reason)
      }
      ''',
      variables: {
        'adminUserId': adminUserId,
        'userId': userId,
        'hours': hours,
        'reason': reason,
      },
    );
  }

  Future<void> adminShadowBanUser({
    required String adminUserId,
    required String userId,
    String? reason,
  }) async {
    await _query(
      '''
      mutation AdminShadowBanUser(
        ${r'$'}adminUserId: ID!,
        ${r'$'}userId: ID!,
        ${r'$'}reason: String
      ) {
        adminShadowBanUser(adminUserId: ${r'$'}adminUserId, userId: ${r'$'}userId, reason: ${r'$'}reason)
      }
      ''',
      variables: {
        'adminUserId': adminUserId,
        'userId': userId,
        'reason': reason,
      },
    );
  }

  Future<void> adminDeleteBanUser({
    required String adminUserId,
    required String userId,
    String? phone,
    String? deviceId,
    String? reason,
  }) async {
    await _query(
      '''
      mutation AdminDeleteBanUser(
        ${r'$'}adminUserId: ID!,
        ${r'$'}userId: ID!,
        ${r'$'}phone: String,
        ${r'$'}deviceId: String,
        ${r'$'}reason: String
      ) {
        adminDeleteBanUser(
          adminUserId: ${r'$'}adminUserId,
          userId: ${r'$'}userId,
          phone: ${r'$'}phone,
          deviceId: ${r'$'}deviceId,
          reason: ${r'$'}reason
        )
      }
      ''',
      variables: {
        'adminUserId': adminUserId,
        'userId': userId,
        'phone': phone,
        'deviceId': deviceId,
        'reason': reason,
      },
    );
  }

  Future<void> adminApproveMarketplace({
    required String adminUserId,
    required String userId,
    required String certificateTitle,
  }) async {
    await _query(
      '''
      mutation AdminApproveMarketplace(
        ${r'$'}adminUserId: ID!,
        ${r'$'}userId: ID!,
        ${r'$'}certificateTitle: String!
      ) {
        adminApproveMarketplace(
          adminUserId: ${r'$'}adminUserId,
          userId: ${r'$'}userId,
          certificateTitle: ${r'$'}certificateTitle
        )
      }
      ''',
      variables: {
        'adminUserId': adminUserId,
        'userId': userId,
        'certificateTitle': certificateTitle,
      },
    );
  }

  Future<void> adminGrantMeritMarketplace({
    required String adminUserId,
    required String userId,
    required String certificateTitle,
    required String reason,
  }) async {
    await _query(
      '''
      mutation AdminGrantMeritMarketplace(
        ${r'$'}adminUserId: ID!,
        ${r'$'}userId: ID!,
        ${r'$'}certificateTitle: String!,
        ${r'$'}reason: String!
      ) {
        adminGrantMeritMarketplace(
          adminUserId: ${r'$'}adminUserId,
          userId: ${r'$'}userId,
          certificateTitle: ${r'$'}certificateTitle,
          reason: ${r'$'}reason
        )
      }
      ''',
      variables: {
        'adminUserId': adminUserId,
        'userId': userId,
        'certificateTitle': certificateTitle,
        'reason': reason,
      },
    );
  }

  Future<void> adminSetTalentFeatured({
    required String adminUserId,
    required String userId,
    required bool isFeatured,
  }) async {
    await _query(
      '''
      mutation AdminSetTalentFeatured(
        ${r'$'}adminUserId: ID!,
        ${r'$'}userId: ID!,
        ${r'$'}isFeatured: Boolean!
      ) {
        adminSetTalentFeatured(
          adminUserId: ${r'$'}adminUserId,
          userId: ${r'$'}userId,
          isFeatured: ${r'$'}isFeatured
        )
      }
      ''',
      variables: {
        'adminUserId': adminUserId,
        'userId': userId,
        'isFeatured': isFeatured,
      },
    );
  }

  Future<void> adminReviewAd({
    required String adminUserId,
    required String adId,
    required String targeting,
    required bool approved,
    String? note,
  }) async {
    await _query(
      '''
      mutation AdminReviewAd(
        ${r'$'}adminUserId: ID!,
        ${r'$'}adId: ID!,
        ${r'$'}targeting: String!,
        ${r'$'}approved: Boolean!,
        ${r'$'}note: String
      ) {
        adminReviewAd(
          adminUserId: ${r'$'}adminUserId,
          adId: ${r'$'}adId,
          targeting: ${r'$'}targeting,
          approved: ${r'$'}approved,
          note: ${r'$'}note
        )
      }
      ''',
      variables: {
        'adminUserId': adminUserId,
        'adId': adId,
        'targeting': targeting,
        'approved': approved,
        'note': note,
      },
    );
  }

  Future<List<Map<String, dynamic>>> adminActionLogs({int limit = 50}) async {
    final data = await _query(
      '''
      query AdminActionLogs(${r'$'}limit: Int) {
        adminActionLogs(limit: ${r'$'}limit) {
          id
          adminUserId
          action
          targetUserId
          targetEntity
          reason
          createdAt
        }
      }
      ''',
      variables: {'limit': limit},
    );

    final items = data['adminActionLogs'] as List<dynamic>;
    return items.map((e) => (e as Map<String, dynamic>)).toList(growable: false);
  }

  Future<void> blockUser({
    required String blockerId,
    required String blockedId,
    String? reasonCode,
  }) async {
    await _query(
      '''
      mutation BlockUser(
        ${r'$'}blockerId: ID!,
        ${r'$'}blockedId: ID!,
        ${r'$'}reasonCode: BlockReasonCode
      ) {
        blockUser(blockerId: ${r'$'}blockerId, blockedId: ${r'$'}blockedId, reasonCode: ${r'$'}reasonCode)
      }
      ''',
      variables: {
        'blockerId': blockerId,
        'blockedId': blockedId,
        'reasonCode': reasonCode,
      },
    );
  }

  Future<void> unblockUser({required String blockerId, required String blockedId}) async {
    await _query(
      '''
      mutation UnblockUser(${r'$'}blockerId: ID!, ${r'$'}blockedId: ID!) {
        unblockUser(blockerId: ${r'$'}blockerId, blockedId: ${r'$'}blockedId)
      }
      ''',
      variables: {
        'blockerId': blockerId,
        'blockedId': blockedId,
      },
    );
  }

  Future<void> muteUser({required String muterId, required String mutedId}) async {
    await _query(
      '''
      mutation MuteUser(${r'$'}muterId: ID!, ${r'$'}mutedId: ID!) {
        muteUser(muterId: ${r'$'}muterId, mutedId: ${r'$'}mutedId)
      }
      ''',
      variables: {'muterId': muterId, 'mutedId': mutedId},
    );
  }

  Future<void> unmuteUser({required String muterId, required String mutedId}) async {
    await _query(
      '''
      mutation UnmuteUser(${r'$'}muterId: ID!, ${r'$'}mutedId: ID!) {
        unmuteUser(muterId: ${r'$'}muterId, mutedId: ${r'$'}mutedId)
      }
      ''',
      variables: {'muterId': muterId, 'mutedId': mutedId},
    );
  }

  Future<void> reportUser({
    required String reporterId,
    required String reportedId,
    required String reasonCode,
    String? detail,
  }) async {
    await _query(
      '''
      mutation ReportUser(
        ${r'$'}reporterId: ID!,
        ${r'$'}reportedId: ID!,
        ${r'$'}reasonCode: ReportReasonCode!,
        ${r'$'}detail: String
      ) {
        reportUser(
          reporterId: ${r'$'}reporterId,
          reportedId: ${r'$'}reportedId,
          reasonCode: ${r'$'}reasonCode,
          detail: ${r'$'}detail
        )
      }
      ''',
      variables: {
        'reporterId': reporterId,
        'reportedId': reportedId,
        'reasonCode': reasonCode,
        'detail': detail,
      },
    );
  }

  Future<List<Map<String, dynamic>>> blockedAccounts(String userId) async {
    final data = await _query(
      '''
      query BlockedAccounts(${r'$'}userId: ID!) {
        blockedAccounts(userId: ${r'$'}userId) {
          userId
          displayName
          profilePictureUrl
          blockedAt
        }
      }
      ''',
      variables: {'userId': userId},
    );

    final items = data['blockedAccounts'] as List<dynamic>;
    return items.map((e) => (e as Map<String, dynamic>)).toList(growable: false);
  }
}
