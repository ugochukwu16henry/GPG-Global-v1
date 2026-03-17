import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../backend/providers/backend_live_providers.dart';
import 'glass_card.dart';

class GatheringPlaceHierarchyPanel extends ConsumerWidget {
  const GatheringPlaceHierarchyPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gatheringPlaceControllerProvider);

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gathering Place Hierarchy',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textOnSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Global Community (Wide Porch) → Local Gathering Place (Anchor) → Sub-Groups (Interest Circles)',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: state.isLoading
                    ? null
                    : () => ref
                        .read(gatheringPlaceControllerProvider.notifier)
                        .bootstrapLocalAnchor(),
                child: const Text('Bootstrap Local Anchor'),
              ),
              FilledButton.tonal(
                onPressed: state.isLoading
                    ? null
                    : () => ref
                        .read(gatheringPlaceControllerProvider.notifier)
                        .discoverNearby(latitude: 6.5244, longitude: 3.3792),
                child: const Text('Discover Nearby (20mi)'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (state.isLoading) const LinearProgressIndicator(),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: AppColors.warmCrimson, fontSize: 11),
              ),
            ),
          if (state.handshakeMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                state.handshakeMessage!,
                style: const TextStyle(color: AppColors.stewardshipGreen, fontSize: 11),
              ),
            ),
          const SizedBox(height: 8),
          ...state.nearbyPlaces.map((place) {
            final groups = (place['groups'] as List<dynamic>? ?? const []);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${place['name']} · ${((place['distanceMiles'] ?? 0.0) as num).toStringAsFixed(1)} mi',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  Text(
                    '${place['stateOrCity']}, ${place['country']} ${place['lga'] != null ? '· ${place['lga']}' : ''}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: groups
                        .map(
                          (group) => Chip(
                            label: Text(
                              '${group['name']} (${group['category']})',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: state.isLoading
                            ? null
                            : () => ref
                                .read(gatheringPlaceControllerProvider.notifier)
                                .checkIn(place['id'].toString()),
                        child: const Text('Check-In'),
                      ),
                      FilledButton.tonal(
                        onPressed: state.isLoading
                            ? null
                            : () => ref
                                .read(gatheringPlaceControllerProvider.notifier)
                                .createInterestCircle(
                                  gatheringPlaceId: place['id'].toString(),
                                  circleName: 'Self-Reliance Workshop',
                                  category: 'SELF_RELIANCE',
                                ),
                        child: const Text('Add Self-Reliance Circle'),
                      ),
                      FilledButton.tonal(
                        onPressed: state.isLoading
                            ? null
                            : () => ref
                                .read(gatheringPlaceControllerProvider.notifier)
                                .createInterestCircle(
                                  gatheringPlaceId: place['id'].toString(),
                                  circleName: 'Temple Prep Class',
                                  category: 'TEMPLE_PREP',
                                ),
                        child: const Text('Add Temple Prep'),
                      ),
                      FilledButton.tonal(
                        onPressed: state.isLoading
                            ? null
                            : () => ref
                                .read(gatheringPlaceControllerProvider.notifier)
                                .createInterestCircle(
                                  gatheringPlaceId: place['id'].toString(),
                                  circleName: 'GPG Football Club',
                                  category: 'SOCIAL',
                                ),
                        child: const Text('Add Football Club'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
