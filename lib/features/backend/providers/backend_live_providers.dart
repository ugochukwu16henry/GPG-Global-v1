import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/backend_gateway.dart';
import '../api/backend_realtime_service.dart';

final backendBaseUrlProvider = Provider<String>((ref) {
  const configured = String.fromEnvironment('GPG_BACKEND_URL');
  if (configured.isNotEmpty) {
    return configured;
  }
  return 'http://localhost:4100';
});

final backendUserIdProvider = StateProvider<String>((ref) => 'demo-user-1');

final backendGatewayProvider = Provider<BackendGateway>((ref) {
  return BackendGateway(
    baseUrl: ref.watch(backendBaseUrlProvider),
    userId: ref.watch(backendUserIdProvider),
  );
});

final backendRealtimeProvider = Provider<BackendRealtimeService>((ref) {
  final service = BackendRealtimeService(baseUrl: ref.watch(backendBaseUrlProvider));
  service.connect();
  ref.onDispose(service.dispose);
  return service;
});

final backendRedFlagStreamProvider = StreamProvider<String>((ref) {
  final realtime = ref.watch(backendRealtimeProvider);
  return realtime.redFlags;
});

class BackendDemoState {
  const BackendDemoState({
    this.isLoading = false,
    this.missionSuggestions = const <String>[],
    this.peerMatchSummary,
    this.checkoutUrl,
    this.moderationResult,
    this.error,
  });

  final bool isLoading;
  final List<String> missionSuggestions;
  final String? peerMatchSummary;
  final String? checkoutUrl;
  final String? moderationResult;
  final String? error;

  BackendDemoState copyWith({
    bool? isLoading,
    List<String>? missionSuggestions,
    String? peerMatchSummary,
    String? checkoutUrl,
    String? moderationResult,
    String? error,
  }) {
    return BackendDemoState(
      isLoading: isLoading ?? this.isLoading,
      missionSuggestions: missionSuggestions ?? this.missionSuggestions,
      peerMatchSummary: peerMatchSummary ?? this.peerMatchSummary,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      moderationResult: moderationResult ?? this.moderationResult,
      error: error,
    );
  }
}

class BackendDemoController extends StateNotifier<BackendDemoState> {
  BackendDemoController(this._read) : super(const BackendDemoState());

  final Ref _read;

  Future<void> runMissionSearch(String queryText) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gateway = _read.read(backendGatewayProvider);
      final suggestions = await gateway.suggestMissions(queryText);
      var summary = '';
      if (suggestions.isNotEmpty) {
        summary = await gateway.missionPeerMatchSummary('demo-mission-id');
      }
      state = state.copyWith(
        isLoading: false,
        missionSuggestions: suggestions,
        peerMatchSummary: summary.isEmpty ? null : summary,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> createCheckout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gateway = _read.read(backendGatewayProvider);
      final userId = _read.read(backendUserIdProvider);
      final checkoutUrl = await gateway.createMarketplaceCheckout(userId);
      state = state.copyWith(
        isLoading: false,
        checkoutUrl: checkoutUrl,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> sendModerationProbe() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gateway = _read.read(backendGatewayProvider);
      final userId = _read.read(backendUserIdProvider);
      final result = await gateway.sendChatForModeration(
        senderUserId: userId,
        roomId: 'global-ysa-room',
        body: 'You are stupid and should leave this group.',
      );
      state = state.copyWith(
        isLoading: false,
        moderationResult: result ?? 'No violation detected by guardrails.',
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }
}

final backendDemoControllerProvider =
    StateNotifierProvider<BackendDemoController, BackendDemoState>((ref) {
  return BackendDemoController(ref);
});
