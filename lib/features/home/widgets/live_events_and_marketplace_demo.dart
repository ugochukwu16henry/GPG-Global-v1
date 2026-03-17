import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/mock_data_provider.dart';
import 'glass_card.dart';

/// Small demo integration strip:
/// - horizontally scrollable live events (birthday/chat)
/// - marketplace filter chips + filtered mock listings
class LiveEventsAndMarketplaceDemo extends ConsumerWidget {
  const LiveEventsAndMarketplaceDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveEvents = ref.watch(liveEventsProvider);
    final listings = ref.watch(filteredMarketplaceListingsProvider);
    final selectedCategory = ref.watch(selectedMarketplaceCategoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live activity · Demo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: liveEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final event = liveEvents[index];
                    final color = switch (event.type) {
                      'Birthday' => AppColors.pathwayAmber,
                      'Chat' => AppColors.primaryNavy,
                      _ => AppColors.primaryNavy.withValues(alpha: 0.85),
                    };
                    final icon = switch (event.type) {
                      'Birthday' => Icons.cake_rounded,
                      'Chat' => Icons.chat_bubble_rounded,
                      _ => Icons.star_rounded,
                    };
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 16, color: color),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  event.message,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textOnSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  event.timestampLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marketplace demo filter',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildFilterChip(ref, label: 'All', value: null, selected: selectedCategory == null),
                  _buildFilterChip(ref, label: 'Tech', value: 'Tech', selected: selectedCategory == 'Tech'),
                  _buildFilterChip(ref, label: 'Tutoring', value: 'Tutoring', selected: selectedCategory == 'Tutoring'),
                  _buildFilterChip(ref, label: 'Creative', value: 'Creative', selected: selectedCategory == 'Creative'),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                children: listings
                    .map(
                      (listing) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.work_rounded,
                                size: 16,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listing.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textOnSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${listing.category} · ${listing.location}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref, {
    required String label,
    required String? value,
    required bool selected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        ref.read(selectedMarketplaceCategoryProvider.notifier).state = value;
      },
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? AppColors.primaryNavy : AppColors.textMuted,
      ),
      selectedColor: AppColors.pathwayAmber.withValues(alpha: 0.3),
      backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected
              ? AppColors.pathwayAmber.withValues(alpha: 0.9)
              : AppColors.primaryNavy.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

