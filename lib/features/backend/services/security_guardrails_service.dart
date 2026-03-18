import 'dart:collection';

class ReportTicket {
  const ReportTicket({
    required this.reportId,
    required this.postId,
    required this.reporterId,
    required this.reason,
    required this.createdAt,
  });

  final String reportId;
  final String postId;
  final String reporterId;
  final String reason;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'postId': postId,
      'reporterId': reporterId,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ModerationDecision {
  const ModerationDecision({
    required this.requiresAdminReview,
    required this.label,
  });

  final bool requiresAdminReview;
  final String label;
}

abstract class LlamaModerationHook {
  Future<ModerationDecision> evaluateReport(ReportTicket ticket);
}

class ReportSubmission {
  const ReportSubmission({
    required this.ticket,
    this.decision,
  });

  final ReportTicket ticket;
  final ModerationDecision? decision;
}

class SecurityGuardrailsService {
  SecurityGuardrailsService({LlamaModerationHook? moderationHook})
      : _moderationHook = moderationHook;

  final LlamaModerationHook? _moderationHook;
  final Map<String, Set<String>> _blockedByUser = {};

  UnmodifiableSetView<String> blockedUsersFor(String userId) {
    return UnmodifiableSetView(
      _blockedByUser[userId]?.toSet() ?? <String>{},
    );
  }

  void blockUser({required String ownerId, required String blockedUserId}) {
    _validateId(ownerId, 'ownerId');
    _validateId(blockedUserId, 'blockedUserId');
    if (ownerId == blockedUserId) {
      throw ArgumentError('A user cannot block themselves.');
    }
    final blockedSet = _blockedByUser.putIfAbsent(ownerId, () => <String>{});
    blockedSet.add(blockedUserId);
  }

  void unblockUser({required String ownerId, required String blockedUserId}) {
    _validateId(ownerId, 'ownerId');
    _validateId(blockedUserId, 'blockedUserId');
    _blockedByUser[ownerId]?.remove(blockedUserId);
  }

  List<String> applyBlockListToFeed({
    required String ownerId,
    required List<String> feedAuthorIds,
  }) {
    _validateId(ownerId, 'ownerId');
    final blocked = _blockedByUser[ownerId] ?? <String>{};
    return feedAuthorIds
        .where((authorId) => !blocked.contains(authorId))
        .toList(
          growable: false,
        );
  }

  Future<ReportSubmission> reportContent({
    required String reporterId,
    required String postId,
    String reason = 'Community standards review',
  }) async {
    _validateId(reporterId, 'reporterId');
    _validateId(postId, 'postId');
    final ticket = ReportTicket(
      reportId:
          '${reporterId}_${postId}_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      reporterId: reporterId,
      reason: reason,
      createdAt: DateTime.now().toUtc(),
    );

    if (_moderationHook == null) {
      return ReportSubmission(ticket: ticket);
    }

    final decision = await _moderationHook.evaluateReport(ticket);
    return ReportSubmission(ticket: ticket, decision: decision);
  }

  Map<String, dynamic> packageReportForAdmin(ReportTicket ticket) {
    return {
      'frankingMethod': 'admin_review_queue',
      'payload': {
        'postId': ticket.postId,
        'reportId': ticket.reportId,
        'reporterId': ticket.reporterId,
        'reason': ticket.reason,
        'timestampUtc': ticket.createdAt.toIso8601String(),
      },
    };
  }

  void _validateId(String value, String fieldName) {
    if (value.trim().isEmpty) {
      throw ArgumentError('$fieldName cannot be empty.');
    }
  }
}
