import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppRole { guest, user, moderator, admin }

enum CommunityIdentity { member, friendSeeker }

class ModeratorInviteCode {
  const ModeratorInviteCode({
    required this.code,
    required this.gatheringPlace,
    required this.role,
    required this.createdAt,
    this.isActive = true,
  });

  final String code;
  final String gatheringPlace;
  final String role;
  final DateTime createdAt;
  final bool isActive;

  ModeratorInviteCode copyWith({bool? isActive}) {
    return ModeratorInviteCode(
      code: code,
      gatheringPlace: gatheringPlace,
      role: role,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class SessionState {
  const SessionState({
    this.role = AppRole.guest,
    this.displayName,
    this.identity = CommunityIdentity.friendSeeker,
    this.moderatorGatheringPlace,
    this.moderatorRole,
    this.sessionToken,
    this.statusMessage,
  });

  final AppRole role;
  final String? displayName;
  final CommunityIdentity identity;
  final String? moderatorGatheringPlace;
  final String? moderatorRole;
  final String? sessionToken;
  final String? statusMessage;

  bool get isAuthenticated => role != AppRole.guest;

  SessionState copyWith({
    AppRole? role,
    String? displayName,
    CommunityIdentity? identity,
    String? moderatorGatheringPlace,
    String? moderatorRole,
    String? sessionToken,
    String? statusMessage,
  }) {
    return SessionState(
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      identity: identity ?? this.identity,
      moderatorGatheringPlace: moderatorGatheringPlace ?? this.moderatorGatheringPlace,
      moderatorRole: moderatorRole ?? this.moderatorRole,
      sessionToken: sessionToken ?? this.sessionToken,
      statusMessage: statusMessage,
    );
  }
}

class ModeratorInviteCodeController extends StateNotifier<List<ModeratorInviteCode>> {
  ModeratorInviteCodeController()
      : super(const [
          ModeratorInviteCode(
            code: 'LAGOS-MOD-2026',
            gatheringPlace: 'Lagos Island Gathering Place',
            role: 'Service Moderator',
            createdAt: DateTime(2026, 3, 17),
          ),
        ]);

  String generateCode({required String gatheringPlace, required String role}) {
    final random = Random();
    final suffix = (1000 + random.nextInt(9000)).toString();
    final safePlace = gatheringPlace
        .split(' ')
        .take(1)
        .join()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z]'), '');
    final code = '${safePlace.isEmpty ? 'GPG' : safePlace}-$suffix';

    state = [
      ModeratorInviteCode(
        code: code,
        gatheringPlace: gatheringPlace,
        role: role,
        createdAt: DateTime.now(),
      ),
      ...state,
    ];
    return code;
  }

  ModeratorInviteCode? consumeCode(String code) {
    final index = state.indexWhere((item) => item.code == code && item.isActive);
    if (index == -1) return null;

    final entry = state[index];
    final next = [...state];
    next[index] = entry.copyWith(isActive: false);
    state = next;
    return entry;
  }
}

final moderatorInviteCodeProvider =
    StateNotifierProvider<ModeratorInviteCodeController, List<ModeratorInviteCode>>((ref) {
  return ModeratorInviteCodeController();
});

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._read) : super(const SessionState());

  final Ref _read;

  void signInUser({required String displayName}) {
    state = state.copyWith(role: AppRole.user, displayName: displayName, statusMessage: null);
  }

  void signUpUser({
    required String displayName,
    required CommunityIdentity identity,
  }) {
    state = state.copyWith(
      role: AppRole.user,
      displayName: displayName,
      identity: identity,
      statusMessage: null,
    );
  }

  bool signInModeratorWithCode(String code) {
    final entry = _read.read(moderatorInviteCodeProvider.notifier).consumeCode(code.trim());
    if (entry == null) {
      state = state.copyWith(statusMessage: 'Invalid or expired moderator code.');
      return false;
    }

    state = state.copyWith(
      role: AppRole.moderator,
      displayName: 'Moderator',
      moderatorGatheringPlace: entry.gatheringPlace,
      moderatorRole: entry.role,
      statusMessage: null,
    );
    return true;
  }

  bool signInAdmin(String secret) {
    if (secret.trim() != 'GPG-ADMIN-2026') {
      state = state.copyWith(statusMessage: 'Invalid admin access key.');
      return false;
    }
    state = state.copyWith(role: AppRole.admin, displayName: 'GPG Admin', statusMessage: null);
    return true;
  }

  void setAdminSession({required String userId, required String sessionToken}) {
    state = state.copyWith(
      role: AppRole.admin,
      displayName: 'GPG Admin',
      sessionToken: sessionToken,
      statusMessage: null,
    );
  }

  void convertFriendToMember() {
    state = state.copyWith(
      identity: CommunityIdentity.member,
      statusMessage:
          'Welcome to Member status! New Member Resources are now available (Ward locator, Gospel Library, Temple Prep).',
    );
  }

  void setStatusMessage(String message) {
    state = state.copyWith(statusMessage: message);
  }

  void signOut() {
    state = const SessionState();
  }
}

final sessionControllerProvider = StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController(ref);
});
