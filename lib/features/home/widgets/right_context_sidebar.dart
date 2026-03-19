import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/mock_data_provider.dart';
import 'glass_card.dart';

class RightContextSidebar extends ConsumerWidget {
  const RightContextSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(liveEventsProvider);
    final birthdays =
        events.where((e) => e.type == 'Birthday').toList(growable: false);

    final marketplace = ref.watch(filteredMarketplaceListingsProvider);
    final topTalents = marketplace.take(4).toList(growable: false);

    final chatPreviews = ref.watch(missionPeerChatPreviewProvider);

    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(12),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Birthdays Today',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textOnSurface,
                ),
              ),
              const SizedBox(height: 10),
              if (birthdays.isEmpty)
                Text(
                  'No birthdays yet.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                )
              else
                ...birthdays.take(3).map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.cake_rounded,
                                size: 16, color: AppColors.pathwayAmber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.message,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                      color: AppColors.textOnSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    e.timestampLabel,
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
                      ),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          padding: const EdgeInsets.all(12),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trending Talents in Your Country',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textOnSurface,
                ),
              ),
              const SizedBox(height: 10),
              ...topTalents.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.trending_up_rounded,
                          size: 16, color: AppColors.primaryNavy),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                                color: AppColors.textOnSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${t.category} · ${t.location}',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          padding: const EdgeInsets.all(12),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Study Group Chat Shortcuts',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textOnSurface,
                ),
              ),
              const SizedBox(height: 10),
              ...chatPreviews.take(3).map(
                    (m) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.chat_bubble_rounded,
                          size: 18, color: AppColors.primaryNavy),
                      title: Text(
                        m.senderName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(
                        m.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Open chat.')),
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
