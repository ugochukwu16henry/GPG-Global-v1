import 'dart:async';
import 'dart:convert';

class AuthorizedBirthdayNotification {
  const AuthorizedBirthdayNotification({
    required this.userId,
    required this.displayName,
    required this.dateIso,
  });

  final String userId;
  final String displayName;
  final String dateIso;

  factory AuthorizedBirthdayNotification.fromJson(Map<String, dynamic> json) {
    final userId = json['userId'];
    final displayName = json['displayName'];
    final dateIso = json['dateIso'];

    if (userId is! String || displayName is! String || dateIso is! String) {
      throw const FormatException('Invalid authorized birthday payload.');
    }

    return AuthorizedBirthdayNotification(
      userId: userId,
      displayName: displayName,
      dateIso: dateIso,
    );
  }
}

class MissionPeerChatRequest {
  const MissionPeerChatRequest({
    required this.fromUserId,
    required this.fromDisplayName,
    required this.missionId,
    required this.sentAtIso,
  });

  final String fromUserId;
  final String fromDisplayName;
  final String missionId;
  final String sentAtIso;

  factory MissionPeerChatRequest.fromJson(Map<String, dynamic> json) {
    final fromUserId = json['fromUserId'];
    final fromDisplayName = json['fromDisplayName'];
    final missionId = json['missionId'];
    final sentAtIso = json['sentAtIso'];

    if (fromUserId is! String ||
        fromDisplayName is! String ||
        missionId is! String ||
        sentAtIso is! String) {
      throw const FormatException('Invalid mission peer chat request payload.');
    }

    return MissionPeerChatRequest(
      fromUserId: fromUserId,
      fromDisplayName: fromDisplayName,
      missionId: missionId,
      sentAtIso: sentAtIso,
    );
  }
}

class JsonMockServiceProvider {
  const JsonMockServiceProvider();

  static const String _authorizedBirthdayJson = '''
[
  {"userId":"u101","displayName":"Amina O.","dateIso":"2026-03-20"},
  {"userId":"u202","displayName":"David K.","dateIso":"2026-03-22"}
]
''';

  static const String _missionPeerRequestsJson = '''
[
  {"fromUserId":"u333","fromDisplayName":"Ethan M.","missionId":"ng-lagos-2019","sentAtIso":"2026-03-17T10:45:00Z"},
  {"fromUserId":"u404","fromDisplayName":"Grace A.","missionId":"gh-accra-2020","sentAtIso":"2026-03-17T11:15:00Z"}
]
''';

  List<AuthorizedBirthdayNotification> loadAuthorizedBirthdays() {
    final decoded = _decodeJsonArray(_authorizedBirthdayJson);
    return decoded
        .map(AuthorizedBirthdayNotification.fromJson)
        .toList(growable: false);
  }

  List<MissionPeerChatRequest> loadMissionPeerChatRequests() {
    final decoded = _decodeJsonArray(_missionPeerRequestsJson);
    return decoded
        .map(MissionPeerChatRequest.fromJson)
        .toList(growable: false);
  }

  Stream<AuthorizedBirthdayNotification> watchAuthorizedBirthdays({
    Duration interval = const Duration(seconds: 4),
  }) {
    final queue = loadAuthorizedBirthdays();
    if (queue.isEmpty) {
      return const Stream.empty();
    }
    return Stream.periodic(interval, (tick) => queue[tick % queue.length]);
  }

  Stream<MissionPeerChatRequest> watchMissionPeerChatRequests({
    Duration interval = const Duration(seconds: 3),
  }) {
    final queue = loadMissionPeerChatRequests();
    if (queue.isEmpty) {
      return const Stream.empty();
    }
    return Stream.periodic(interval, (tick) => queue[tick % queue.length]);
  }

  List<Map<String, dynamic>> _decodeJsonArray(String source) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException('Invalid mock JSON payload.');
    }

    if (decoded is! List) {
      throw const FormatException('Mock payload must be a JSON list.');
    }

    return decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Mock payload list contains invalid object.');
      }
      return item;
    }).toList(growable: false);
  }
}