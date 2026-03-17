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
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxCardWidth = constraints.maxWidth > 920
                  ? 920.0
                  : constraints.maxWidth;

              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxCardWidth),
                      child: VideoFeedCard(item: items[index]),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
