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

class BackendAuthState {
  const BackendAuthState({
    this.isLoading = false,
    this.phone,
    this.devOtpPreview,
    this.message,
    this.error,
  });

  final bool isLoading;
  final String? phone;
  final String? devOtpPreview;
  final String? message;
  final String? error;

  BackendAuthState copyWith({
    bool? isLoading,
    String? phone,
    String? devOtpPreview,
    String? message,
    String? error,
  }) {
    return BackendAuthState(
      isLoading: isLoading ?? this.isLoading,
      phone: phone ?? this.phone,
      devOtpPreview: devOtpPreview ?? this.devOtpPreview,
      message: message,
      error: error,
    );
  }
}

class BackendAuthController extends StateNotifier<BackendAuthState> {
  BackendAuthController(this._read) : super(const BackendAuthState());

  final Ref _read;

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final gateway = _read.read(backendGatewayProvider);
      final preview = await gateway.sendPhoneOtp(phone);
      state = state.copyWith(
        isLoading: false,
        phone: phone,
        devOtpPreview: preview,
        message: 'OTP sent successfully.',
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> verifyOtp({required String phone, required String otpCode}) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final gateway = _read.read(backendGatewayProvider);
      final userId = await gateway.verifyPhoneOtp(phone: phone, otpCode: otpCode);
      _read.read(backendUserIdProvider.notifier).state = userId;
      state = state.copyWith(
        isLoading: false,
        phone: phone,
        message: 'Phone verified. Active user: $userId',
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }
}

final backendAuthControllerProvider =
    StateNotifierProvider<BackendAuthController, BackendAuthState>((ref) {
  return BackendAuthController(ref);
});

class GatheringPlaceState {
  const GatheringPlaceState({
    this.isLoading = false,
    this.nearbyPlaces = const <Map<String, dynamic>>[],
    this.handshakeMessage,
    this.error,
  });

  final bool isLoading;
  final List<Map<String, dynamic>> nearbyPlaces;
  final String? handshakeMessage;
  final String? error;

  GatheringPlaceState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? nearbyPlaces,
    String? handshakeMessage,
    String? error,
  }) {
    return GatheringPlaceState(
      isLoading: isLoading ?? this.isLoading,
      nearbyPlaces: nearbyPlaces ?? this.nearbyPlaces,
      handshakeMessage: handshakeMessage ?? this.handshakeMessage,
      error: error,
    );
  }
}

class GatheringPlaceController extends StateNotifier<GatheringPlaceState> {
  GatheringPlaceController(this._read) : super(const GatheringPlaceState());

  final Ref _read;

  Future<void> discoverNearby({required double latitude, required double longitude}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gateway = _read.read(backendGatewayProvider);
      final userId = _read.read(backendUserIdProvider);
      final places = await gateway.nearbyGatheringPlaces(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
      );
      state = state.copyWith(isLoading: false, nearbyPlaces: places);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> bootstrapLocalAnchor() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gateway = _read.read(backendGatewayProvider);
      await gateway.createLocalGatheringPlace(
        name: 'Lagos Island Gathering Place',
        country: 'Nigeria',
        stateOrCity: 'Lagos',
        lga: 'Lagos Island',
        latitude: 6.4541,
        longitude: 3.3947,
      );
      await discoverNearby(latitude: 6.5244, longitude: 3.3792);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> createInterestCircle({
    required String gatheringPlaceId,
    required String circleName,
    required String category,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gateway = _read.read(backendGatewayProvider);
      final userId = _read.read(backendUserIdProvider);
      await gateway.createSubGroup(
        gatheringPlaceId: gatheringPlaceId,
        name: circleName,
        category: category,
        adminUserId: userId,
      );
      await discoverNearby(latitude: 6.5244, longitude: 3.3792);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> checkIn(String gatheringPlaceId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gateway = _read.read(backendGatewayProvider);
      final userId = _read.read(backendUserIdProvider);
      final handshake = await gateway.checkInGatheringPlace(
        userId: userId,
        gatheringPlaceId: gatheringPlaceId,
      );
      state = state.copyWith(
        isLoading: false,
        handshakeMessage: handshake,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }
}

final gatheringPlaceControllerProvider =
    StateNotifierProvider<GatheringPlaceController, GatheringPlaceState>((ref) {
  return GatheringPlaceController(ref);
});

class SilentGuardianState {
  const SilentGuardianState({
    this.lastNudge,
    this.lastRiskScore,
    this.lastCategory,
    this.isLoading = false,
    this.error,
  });

  final String? lastNudge;
  final int? lastRiskScore;
  final String? lastCategory;
  final bool isLoading;
  final String? error;

  SilentGuardianState copyWith({
    String? lastNudge,
    int? lastRiskScore,
    String? lastCategory,
    bool? isLoading,
    String? error,
  }) {
    return SilentGuardianState(
      lastNudge: lastNudge ?? this.lastNudge,
      lastRiskScore: lastRiskScore ?? this.lastRiskScore,
      lastCategory: lastCategory ?? this.lastCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SilentGuardianController extends StateNotifier<SilentGuardianState> {
  SilentGuardianController(this._read) : super(const SilentGuardianState());

  final Ref _read;

  ({int riskScore, String category, String nudge}) _scanLocally(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('stupid') || normalized.contains('hate') || normalized.contains('idiot')) {
      return (
        riskScore: 92,
        category: 'DISRESPECTFUL_LANGUAGE',
        nudge: 'This message looks like it might violate our community standards. Are you sure you want to send it?'
      );
    }
    if (normalized.contains('scam') || normalized.contains('send money now')) {
      return (
        riskScore: 95,
        category: 'DISHONEST_CONDUCT',
        nudge: 'Potential scam language detected. Please rephrase before sending.'
      );
    }
    if (normalized.contains('inappropriate') || normalized.contains('immodest')) {
      return (
        riskScore: 91,
        category: 'IMMODEST_INAPPROPRIATE_CONTENT',
        nudge: 'This content may be inappropriate for the Gathering Place.'
      );
    }
    return (
      riskScore: 8,
      category: 'UNWHOLESOME_BEHAVIOR',
      nudge: 'Message appears safe.'
    );
  }

  Future<bool> guardAndSend({
    required String roomId,
    required String body,
    bool userConfirmedAfterNudge = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = _read.read(backendUserIdProvider);
      final gateway = _read.read(backendGatewayProvider);
      final scan = _scanLocally(body);

      state = state.copyWith(
        isLoading: false,
        lastNudge: scan.nudge,
        lastRiskScore: scan.riskScore,
        lastCategory: scan.category,
      );

      if (scan.riskScore >= 70 && !userConfirmedAfterNudge) {
        return false;
      }

      if (scan.riskScore >= 70) {
        await gateway.createSafetyMetadataFlag(
          chatId: roomId,
          flaggedUserId: userId,
          riskScore: scan.riskScore,
          conductCategory: scan.category,
          summary: 'On-device scout detected potential violation pattern.',
        );
      }

      if (scan.riskScore >= 90) {
        await gateway.createAiBreakGlassBundle(
          chatId: roomId,
          reportedUserId: userId,
          conductCategory: scan.category,
          riskScore: scan.riskScore,
          localAiSummary: 'High-risk certainty from on-device model.',
          evidenceMessages: [body],
        );
      }

      await gateway.sendChatForModeration(
        senderUserId: userId,
        roomId: roomId,
        body: body,
      );
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      return false;
    }
  }

  Future<void> reportWithFranking({
    required String roomId,
    required String reportedUserId,
    required String conductCategory,
    required String evidenceMessage,
  }) async {
    final userId = _read.read(backendUserIdProvider);
    final gateway = _read.read(backendGatewayProvider);
    final frankingProof = 'frank-${DateTime.now().millisecondsSinceEpoch}-${roomId.hashCode}';
    await gateway.createUserReportBundle(
      chatId: roomId,
      reporterUserId: userId,
      reportedUserId: reportedUserId,
      conductCategory: conductCategory,
      messageFrankingProof: frankingProof,
      evidenceMessages: [evidenceMessage],
    );
  }
}

final silentGuardianControllerProvider =
    StateNotifierProvider<SilentGuardianController, SilentGuardianState>((ref) {
  return SilentGuardianController(ref);
});

class BreakGlassDeskState {
  const BreakGlassDeskState({
    this.isLoading = false,
    this.bundles = const <Map<String, dynamic>>[],
    this.error,
  });

  final bool isLoading;
  final List<Map<String, dynamic>> bundles;
  final String? error;

  BreakGlassDeskState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? bundles,
    String? error,
  }) {
    return BreakGlassDeskState(
      isLoading: isLoading ?? this.isLoading,
      bundles: bundles ?? this.bundles,
      error: error,
    );
  }
}

class BreakGlassDeskController extends StateNotifier<BreakGlassDeskState> {
  BreakGlassDeskController(this._read) : super(const BreakGlassDeskState());

  final Ref _read;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gateway = _read.read(backendGatewayProvider);
      final bundles = await gateway.breakGlassBundles(limit: 20);
      state = state.copyWith(isLoading: false, bundles: bundles);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> resolve({required String bundleId, required String action}) async {
    final gateway = _read.read(backendGatewayProvider);
    final adminUserId = _read.read(backendUserIdProvider);
    await gateway.resolveBreakGlassBundle(
      bundleId: bundleId,
      adminUserId: adminUserId,
      action: action,
    );
    await refresh();
  }
}

final breakGlassDeskControllerProvider =
    StateNotifierProvider<BreakGlassDeskController, BreakGlassDeskState>((ref) {
  return BreakGlassDeskController(ref);
});
