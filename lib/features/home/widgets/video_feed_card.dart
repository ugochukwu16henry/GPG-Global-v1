import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../backend/providers/boundary_providers.dart';
import '../providers/mock_data_provider.dart';
import 'glass_card.dart';

class VideoFeedCard extends ConsumerStatefulWidget {
  const VideoFeedCard({
    super.key,
    required this.item,
    this.onHireTap,
  });

  final FeedItem item;
  final VoidCallback? onHireTap;

  @override
  ConsumerState<VideoFeedCard> createState() => _VideoFeedCardState();
}

class _VideoFeedCardState extends ConsumerState<VideoFeedCard> {
  bool _isMuted = true;
  bool _isPlaying = false;
  bool _showCaptions = true;
  String _selectedQuality = 'Auto';
  ScrollPosition? _scrollPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _updateVisibilityPlayback());
    final position = Scrollable.of(context).position;
    if (_scrollPosition != position) {
      _scrollPosition?.removeListener(_updateVisibilityPlayback);
      _scrollPosition = position;
      _scrollPosition?.addListener(_updateVisibilityPlayback);
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_updateVisibilityPlayback);
    _scrollPosition = null;
    super.dispose();
  }

  void _updateVisibilityPlayback() {
    if (!mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final size = renderObject.size;
    if (size.height <= 0) return;

    final topLeft = renderObject.localToGlobal(Offset.zero);
    final viewportHeight = MediaQuery.sizeOf(context).height;

    final visibleTop = math.max(0.0, topLeft.dy);
    final visibleBottom = math.min(viewportHeight, topLeft.dy + size.height);
    final visibleHeight = math.max(0.0, visibleBottom - visibleTop);
    final visibleRatio = visibleHeight / size.height;

    final shouldPlay = visibleRatio >= 0.5;
    if (shouldPlay != _isPlaying) {
      setState(() => _isPlaying = shouldPlay);
    }
  }

  double _aspectRatio() {
    return switch (widget.item.videoAspect) {
      VideoAspect.vertical => 9 / 16,
      VideoAspect.square => 1,
      VideoAspect.landscape => 16 / 9,
    };
  }

  List<String> _qualityOptions() {
    final options = <String>{'Auto', ...widget.item.availableResolutions};
    final sorted = options.toList(growable: false);
    sorted.sort((a, b) {
      if (a == 'Auto') return -1;
      if (b == 'Auto') return 1;
      return a.compareTo(b);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final targetUserId = item.ownerUserId ?? item.id;

    return GlassCard(
      borderRadius: 12,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AspectRatio(
              aspectRatio: _aspectRatio(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryNavy.withValues(alpha: 0.85),
                      AppColors.primaryNavy.withValues(alpha: 0.58),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        item.isVideo
                            ? (_isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled)
                            : Icons.article_outlined,
                        size: 52,
                        color: AppColors.pathwayAmber.withValues(alpha: 0.95),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _isPlaying
                              ? (_isMuted
                                  ? 'Auto-play · Muted'
                                  : 'Auto-play · Sound On')
                              : 'Paused',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          PopupMenuButton<String>(
                            tooltip: 'Video Quality',
                            onSelected: (value) =>
                                setState(() => _selectedQuality = value),
                            itemBuilder: (context) => _qualityOptions()
                                .map(
                                  (quality) => PopupMenuItem<String>(
                                    value: quality,
                                    child: Text(quality),
                                  ),
                                )
                                .toList(growable: false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                _selectedQuality,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              _isMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: () =>
                                setState(() => _isMuted = !_isMuted),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              _showCaptions
                                  ? Icons.closed_caption
                                  : Icons.closed_caption_disabled,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: () =>
                                setState(() => _showCaptions = !_showCaptions),
                          ),
                        ],
                      ),
                    ),
                    if (_showCaptions && item.autoCaptions.isNotEmpty)
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 76,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.autoCaptions.first,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
                      AppColors.primaryNavy.withValues(alpha: 0.8),
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
                        fontWeight: FontWeight.w700,
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
                                color: Colors.white.withValues(alpha: 0.82),
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
                              final controller =
                                  ref.read(boundaryControllerProvider.notifier);
                              if (value == 'block') {
                                await controller.blockUser(
                                  blockedId: targetUserId,
                                  reasonCode: 'HARASSMENT',
                                );
                              } else if (value == 'mute') {
                                await controller.muteUser(
                                    mutedId: targetUserId);
                              } else if (value == 'report') {
                                await controller.reportUser(
                                  reportedId: targetUserId,
                                  reasonCode: 'HARASSMENT',
                                  detail: 'Reported from feed card menu',
                                );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                  value: 'block', child: Text('Block User')),
                              PopupMenuItem(
                                  value: 'mute', child: Text('Mute User')),
                              PopupMenuItem(
                                  value: 'report', child: Text('Report User')),
                            ],
                          ),
                        ],
                      ),
                    ],
                    if (item.moderationTags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: item.moderationTags
                            .map(
                              (tag) => Chip(
                                visualDensity: VisualDensity.compact,
                                label: Text(tag,
                                    style: const TextStyle(fontSize: 10)),
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.12),
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _selectedQuality == 'Auto'
                          ? 'Quality: Auto Adaptive (${item.availableResolutions.join('/')})'
                          : 'Quality: $_selectedQuality',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 10,
                      ),
                    ),
                    if (item.timestampComments.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ...item.timestampComments.take(2).map(
                            (comment) => Text(
                              '@${comment.seconds}s · ${comment.body}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 10,
                              ),
                            ),
                          ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonal(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Liked.')),
                            );
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                          child: const Text('Like'),
                        ),
                        if (item.hireEnabled ||
                            item.moderationTags.contains('Skill Showcase'))
                          Material(
                            color: AppColors.pathwayAmber,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                if (widget.onHireTap != null) {
                                  widget.onHireTap!();
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Hire request started.')),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                child: SizedBox(
                                  height: 48,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.person_search,
                                          size: 16,
                                          color: AppColors.primaryNavy),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Hire this Talent',
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
                          ),
                        FilledButton.tonal(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Reshared to Mission Peer / Gathering Place group.')),
                            );
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                          child: const Text('Forward Reshare'),
                        ),
                      ],
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
