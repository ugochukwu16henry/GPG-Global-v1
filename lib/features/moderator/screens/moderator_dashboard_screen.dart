import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/session_provider.dart';
import '../../backend/providers/backend_live_providers.dart';

class ModeratorDashboardScreen extends ConsumerStatefulWidget {
  const ModeratorDashboardScreen({super.key});

  @override
  ConsumerState<ModeratorDashboardScreen> createState() =>
      _ModeratorDashboardScreenState();
}

class _ModeratorDashboardScreenState
    extends ConsumerState<ModeratorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(breakGlassDeskControllerProvider.notifier).refresh();
      await ref
          .read(gatheringPlaceControllerProvider.notifier)
          .discoverNearby(latitude: 6.5244, longitude: 3.3792);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final breakGlass = ref.watch(breakGlassDeskControllerProvider);
    final gathering = ref.watch(gatheringPlaceControllerProvider);
    final realtimeFlag = ref.watch(backendRedFlagStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderator Dashboard'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(backendUserIdProvider.notifier).state = 'anonymous';
              ref.read(sessionControllerProvider.notifier).signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(breakGlassDeskControllerProvider.notifier).refresh();
          await ref
              .read(gatheringPlaceControllerProvider.notifier)
              .discoverNearby(latitude: 6.5244, longitude: 3.3792);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${session.moderatorRole ?? 'Moderator'} · ${session.moderatorGatheringPlace ?? 'Unknown Place'}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Live moderator tools for safety cases and local gathering operations.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Real-Time Safety Alerts',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            realtimeFlag.when(
              data: (value) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warmCrimson.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(value),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Break-Glass Review Queue',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                FilledButton.tonal(
                  onPressed: breakGlass.isLoading
                      ? null
                      : () => ref
                          .read(breakGlassDeskControllerProvider.notifier)
                          .refresh(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (breakGlass.isLoading) const LinearProgressIndicator(),
            if (breakGlass.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  breakGlass.error!,
                  style: const TextStyle(color: AppColors.warmCrimson),
                ),
              ),
            if (breakGlass.bundles.isEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('No open break-glass cases right now.'),
              ),
            ...breakGlass.bundles.map(
              (bundle) => Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryNavy.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk ${bundle['riskScore'] ?? '-'} · ${bundle['conductCategory']}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text('Chat: ${bundle['chatId']}'),
                    Text('Reported user: ${bundle['reportedUserId']}'),
                    if ((bundle['localAiSummary'] ?? '').toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(bundle['localAiSummary'].toString()),
                      ),
                    const SizedBox(height: 8),
                    ...((bundle['evidenceMessages'] as List<dynamic>? ??
                            const [])
                        .take(3)
                        .map((message) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• ${(message as Map<String, dynamic>)['body']}',
                                style:
                                    const TextStyle(color: AppColors.textMuted),
                              ),
                            ))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => ref
                              .read(breakGlassDeskControllerProvider.notifier)
                              .resolve(
                                bundleId: bundle['id'].toString(),
                                action: 'DISMISSED',
                              ),
                          child: const Text('Dismiss'),
                        ),
                        FilledButton.tonal(
                          onPressed: () => ref
                              .read(breakGlassDeskControllerProvider.notifier)
                              .resolve(
                                bundleId: bundle['id'].toString(),
                                action: 'WARNING_SENT',
                              ),
                          child: const Text('Send Warning'),
                        ),
                        FilledButton.tonal(
                          onPressed: () => ref
                              .read(breakGlassDeskControllerProvider.notifier)
                              .resolve(
                                bundleId: bundle['id'].toString(),
                                action: 'SUSPENDED_7_DAYS',
                              ),
                          child: const Text('Suspend 7 Days'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Gathering Place Operations',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                FilledButton.tonal(
                  onPressed: gathering.isLoading
                      ? null
                      : () => ref
                          .read(gatheringPlaceControllerProvider.notifier)
                          .discoverNearby(latitude: 6.5244, longitude: 3.3792),
                  child: const Text('Refresh Nearby'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (gathering.isLoading) const LinearProgressIndicator(),
            if (gathering.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  gathering.error!,
                  style: const TextStyle(color: AppColors.warmCrimson),
                ),
              ),
            if (gathering.handshakeMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  gathering.handshakeMessage!,
                  style: const TextStyle(color: AppColors.stewardshipGreen),
                ),
              ),
            ...gathering.nearbyPlaces.map(
              (place) => Card(
                margin: const EdgeInsets.only(top: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place['name'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${place['stateOrCity']}, ${place['country']}',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.tonal(
                            onPressed: () => ref
                                .read(gatheringPlaceControllerProvider.notifier)
                                .checkIn(place['id'].toString()),
                            child: const Text('Check-In'),
                          ),
                          FilledButton.tonal(
                            onPressed: () => ref
                                .read(gatheringPlaceControllerProvider.notifier)
                                .createInterestCircle(
                                  gatheringPlaceId: place['id'].toString(),
                                  circleName: 'Moderator Safety Circle',
                                  category: 'GENERAL',
                                ),
                            child: const Text('Create Safety Circle'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
