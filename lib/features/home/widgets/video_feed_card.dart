import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/mock_data_provider.dart';
import 'glass_card.dart';

/// Single video/post card: 12px rounded corners and overlay "Hire Talent" button.
class VideoFeedCard extends StatelessWidget {
  const VideoFeedCard({
    super.key,
    required this.item,
  });

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
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
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
