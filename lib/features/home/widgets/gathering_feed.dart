import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mock_data_provider.dart';
import 'video_feed_card.dart';

/// Scrollable Gathering Feed (videos/posts) in the center of the bento grid.
class GatheringFeed extends ConsumerWidget {
  const GatheringFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(gatheringFeedProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Gathering Feed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return VideoFeedCard(item: items[index]);
            },
          ),
        ),
      ],
    );
  }
}
