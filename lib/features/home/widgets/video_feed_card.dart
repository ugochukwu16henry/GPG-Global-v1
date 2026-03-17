import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../backend/providers/boundary_providers.dart';
import '../providers/mock_data_provider.dart';
import 'glass_card.dart';

/// Single video/post card: 12px rounded corners and overlay "Hire Talent" button.
class VideoFeedCard extends ConsumerWidget {
  const VideoFeedCard({
    super.key,
    required this.item,
  });

  final FeedItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      borderRadius: 12,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Placeholder for video thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryNavy.withValues(alpha: 0.85),
                      AppColors.primaryNavy.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    item.isVideo ? Icons.play_circle_filled : Icons.article_outlined,
                    size: 48,
                    color: AppColors.pathwayAmber.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
            // Overlay gradient and "Hire Talent" button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.primaryNavy.withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.subtitle!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_horiz,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            onSelected: (value) async {
                              final controller = ref.read(boundaryControllerProvider.notifier);
                              if (value == 'block') {
                                await controller.blockUser(
                                  blockedId: item.id,
                                  reasonCode: 'HARASSMENT',
                                );
                              } else if (value == 'mute') {
                                await controller.muteUser(mutedId: item.id);
                              } else if (value == 'report') {
                                await controller.reportUser(
                                  reportedId: item.id,
                                  reasonCode: 'HARASSMENT',
                                  detail: 'Reported from feed card menu',
                                );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'block',
                                child: Text('Block User'),
                              ),
                              PopupMenuItem(
                                value: 'mute',
                                child: Text('Mute User'),
                              ),
                              PopupMenuItem(
                                value: 'report',
                                child: Text('Report User'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Material(
                      color: AppColors.pathwayAmber,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_search, size: 16, color: AppColors.primaryNavy),
                              const SizedBox(width: 6),
                              Text(
                                'Hire Talent',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
