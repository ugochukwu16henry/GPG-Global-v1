import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/mock_service_provider.dart';
import '../services/search_filter_service.dart';
import '../services/security_guardrails_service.dart';

final searchFilterServiceProvider = Provider<SearchFilterService>((ref) {
  return const SearchFilterService();
});

final securityGuardrailsServiceProvider = Provider<SecurityGuardrailsService>((ref) {
  return SecurityGuardrailsService();
});

final jsonMockServiceProvider = Provider<JsonMockServiceProvider>((ref) {
  return const JsonMockServiceProvider();
});

final authorizedBirthdayStreamProvider =
    StreamProvider<AuthorizedBirthdayNotification>((ref) {
  final service = ref.watch(jsonMockServiceProvider);
  return service.watchAuthorizedBirthdays();
});

final missionPeerChatStreamProvider =
    StreamProvider<MissionPeerChatRequest>((ref) {
  final service = ref.watch(jsonMockServiceProvider);
  return service.watchMissionPeerChatRequests();
});