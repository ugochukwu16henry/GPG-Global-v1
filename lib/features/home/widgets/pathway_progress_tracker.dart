import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/mock_data_provider.dart';
import 'glass_card.dart';

/// Circular pathway progress tracker (top-right of bento).
class PathwayProgressTracker extends ConsumerWidget {
  const PathwayProgressTracker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(pathwayProgressProvider).toDouble();
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: CircularProgressIndicator(
                    value: progress / 100,
                    strokeWidth: 6,
                    backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pathwayAmber),
                  ),
                ),
                Text(
                  '${progress.toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pathway Progress',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
