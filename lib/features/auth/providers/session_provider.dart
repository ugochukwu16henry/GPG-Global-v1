import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppRole { guest, user, moderator, admin }

enum CommunityIdentity { member, friendSeeker }

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
      moderatorGatheringPlace:
          moderatorGatheringPlace ?? this.moderatorGatheringPlace,
      moderatorRole: moderatorRole ?? this.moderatorRole,
      sessionToken: sessionToken ?? this.sessionToken,
      statusMessage: statusMessage,
    );
  }
}

class SessionController extends StateNotifier<SessionState> {
  SessionController() : super(const SessionState());

  void signInUser({required String displayName}) {
    state = state.copyWith(
        role: AppRole.user, displayName: displayName, statusMessage: null);
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

  void setUserSession({
    required String displayName,
    required CommunityIdentity identity,
    required String sessionToken,
  }) {
    state = state.copyWith(
      role: AppRole.user,
      displayName: displayName,
      identity: identity,
      sessionToken: sessionToken,
      statusMessage: null,
    );
  }

  void setModeratorSession({
    required String sessionToken,
    required String gatheringPlace,
    required String moderatorRole,
  }) {
    state = state.copyWith(
      role: AppRole.moderator,
      displayName: 'Moderator',
      moderatorGatheringPlace: gatheringPlace,
      moderatorRole: moderatorRole,
      sessionToken: sessionToken,
      statusMessage: null,
    );
  }

  bool signInAdmin(String secret) {
    if (secret.trim() != 'GPG-ADMIN-2026') {
      state = state.copyWith(statusMessage: 'Invalid admin access key.');
      return false;
    }
    state = state.copyWith(
        role: AppRole.admin, displayName: 'GPG Admin', statusMessage: null);
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

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController();
});
