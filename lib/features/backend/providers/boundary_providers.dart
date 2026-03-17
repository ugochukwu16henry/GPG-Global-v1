import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backend_live_providers.dart';

class BlockedAccountItem {
  const BlockedAccountItem({
    required this.userId,
    required this.displayName,
    required this.blockedAt,
    this.profilePictureUrl,
  });

  final String userId;
  final String displayName;
  final String blockedAt;
  final String? profilePictureUrl;
}

class BoundaryState {
  const BoundaryState({
    this.isLoading = false,
    this.blockedAccounts = const <BlockedAccountItem>[],
    this.message,
    this.error,
  });

  final bool isLoading;
  final List<BlockedAccountItem> blockedAccounts;
  final String? message;
  final String? error;

  BoundaryState copyWith({
    bool? isLoading,
    List<BlockedAccountItem>? blockedAccounts,
    String? message,
    String? error,
  }) {
    return BoundaryState(
      isLoading: isLoading ?? this.isLoading,
      blockedAccounts: blockedAccounts ?? this.blockedAccounts,
      message: message,
      error: error,
    );
  }
}

class BoundaryController extends StateNotifier<BoundaryState> {
  BoundaryController(this._read) : super(const BoundaryState());

  final Ref _read;

  Future<void> refreshBlockedAccounts() async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final gateway = _read.read(backendGatewayProvider);
      final userId = _read.read(backendUserIdProvider);
      final rows = await gateway.blockedAccounts(userId);
      final items = rows
          .map(
            (row) => BlockedAccountItem(
              userId: (row['userId'] ?? '').toString(),
              displayName: (row['displayName'] ?? '').toString(),
              blockedAt: (row['blockedAt'] ?? '').toString(),
              profilePictureUrl: row['profilePictureUrl']?.toString(),
            ),
          )
          .toList(growable: false);
      state = state.copyWith(isLoading: false, blockedAccounts: items);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> blockUser({required String blockedId, required String reasonCode}) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final gateway = _read.read(backendGatewayProvider);
      final userId = _read.read(backendUserIdProvider);
      await gateway.blockUser(
        blockerId: userId,
        blockedId: blockedId,
        reasonCode: reasonCode,
      );
      await refreshBlockedAccounts();
      state = state.copyWith(isLoading: false, message: 'User blocked successfully.');
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> unblockUser({required String blockedId}) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final gateway = _read.read(backendGatewayProvider);
      final userId = _read.read(backendUserIdProvider);
      await gateway.unblockUser(blockerId: userId, blockedId: blockedId);
      await refreshBlockedAccounts();
      state = state.copyWith(
        isLoading: false,
        message: 'Unblocked. Re-block cooldown applies for 24 hours.',
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> muteUser({required String mutedId}) async {
    try {
      final gateway = _read.read(backendGatewayProvider);
      final userId = _read.read(backendUserIdProvider);
      await gateway.muteUser(muterId: userId, mutedId: mutedId);
      state = state.copyWith(message: 'User muted.');
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> reportUser({
    required String reportedId,
    required String reasonCode,
    String? detail,
  }) async {
    try {
      final gateway = _read.read(backendGatewayProvider);
      final userId = _read.read(backendUserIdProvider);
      await gateway.reportUser(
        reporterId: userId,
        reportedId: reportedId,
        reasonCode: reasonCode,
        detail: detail,
      );
      state = state.copyWith(message: 'Report sent to Admins for Stepwise Discipline.');
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }
}

final boundaryControllerProvider =
    StateNotifierProvider<BoundaryController, BoundaryState>((ref) {
  return BoundaryController(ref);
});
