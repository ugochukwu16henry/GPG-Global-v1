import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backend/providers/backend_live_providers.dart';
import 'mock_data_provider.dart';

class LiveFeedState {
  const LiveFeedState({
    this.isLoading = false,
    this.items = const <FeedItem>[],
    this.error,
    this.lastUploadedMediaPath,
    this.lastUploadedMediaPreviewUrl,
  });

  final bool isLoading;
  final List<FeedItem> items;
  final String? error;
  final String? lastUploadedMediaPath;
  final String? lastUploadedMediaPreviewUrl;

  LiveFeedState copyWith({
    bool? isLoading,
    List<FeedItem>? items,
    String? error,
    String? lastUploadedMediaPath,
    String? lastUploadedMediaPreviewUrl,
  }) {
    return LiveFeedState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
      lastUploadedMediaPath:
          lastUploadedMediaPath ?? this.lastUploadedMediaPath,
      lastUploadedMediaPreviewUrl:
          lastUploadedMediaPreviewUrl ?? this.lastUploadedMediaPreviewUrl,
    );
  }
}

class LiveFeedController extends StateNotifier<LiveFeedState> {
  LiveFeedController(this._ref) : super(const LiveFeedState());

  final Ref _ref;

  bool _isLikelyVideo(String? mediaUrl) {
    if (mediaUrl == null) return false;
    final lower = mediaUrl.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.m4v');
  }

  FeedItem _toFeedItem(Map<String, dynamic> row) {
    final captions = ((row['captions'] as List<dynamic>?) ?? const <dynamic>[])
        .map((value) => value.toString())
        .toList(growable: false);
    final tags =
        ((row['moderationTags'] as List<dynamic>?) ?? const <dynamic>[])
            .map((value) => value.toString())
            .toList(growable: false);
    final resolutions =
        ((row['availableResolutions'] as List<dynamic>?) ?? const <dynamic>[])
            .map((value) => value.toString())
            .toList(growable: false);
    final author =
        (row['author'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final textBody = (row['textBody'] ?? '').toString();
    final skill = (row['skillHighlight'] ?? '').toString();
    final subtitleParts = <String>[
      if ((author['displayName'] ?? '').toString().isNotEmpty)
        (author['displayName'] ?? '').toString(),
      if (skill.isNotEmpty) skill,
      if (row['isBoosted'] == true) 'Boosted',
    ];

    return FeedItem(
      id: (row['id'] ?? '').toString(),
      ownerUserId: (author['id'] ?? '').toString(),
      title: textBody.isNotEmpty
          ? textBody
          : (skill.isNotEmpty ? skill : 'GPG Post'),
      subtitle: subtitleParts.isEmpty ? null : subtitleParts.join(' · '),
      isVideo: _isLikelyVideo(row['mediaUrl']?.toString()),
      avatarUrl: author['profilePictureUrl']?.toString(),
      autoCaptions: captions,
      moderationTags: tags,
      hireEnabled: skill.isNotEmpty,
      availableResolutions: resolutions.isEmpty
          ? const <String>['240p', '480p', '720p']
          : resolutions,
    );
  }

  Future<void> refresh({int limit = 20}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rows = await _ref.read(backendGatewayProvider).feed(limit: limit);
      state = state.copyWith(
        isLoading: false,
        items: rows.map(_toFeedItem).toList(growable: false),
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  void setUploadedMedia({required String path, required String previewUrl}) {
    state = state.copyWith(
      lastUploadedMediaPath: path,
      lastUploadedMediaPreviewUrl: previewUrl,
    );
  }

  void clearComposerMedia() {
    state = state.copyWith(
      lastUploadedMediaPath: '',
      lastUploadedMediaPreviewUrl: '',
    );
  }

  Future<void> publishPost({
    required String textBody,
    String? skillHighlight,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = _ref.read(backendUserIdProvider);
      await _ref.read(backendGatewayProvider).createPost(
            authorUserId: userId,
            textBody: textBody.trim().isEmpty ? null : textBody.trim(),
            mediaUrl: state.lastUploadedMediaPath?.isEmpty == true
                ? null
                : state.lastUploadedMediaPath,
            skillHighlight:
                skillHighlight != null && skillHighlight.trim().isEmpty
                    ? null
                    : skillHighlight,
            moderationTags: state.lastUploadedMediaPath?.isNotEmpty == true
                ? const <String>['USER_UPLOAD']
                : null,
          );
      await refresh();
      state = state.copyWith(
        isLoading: false,
        lastUploadedMediaPath: '',
        lastUploadedMediaPreviewUrl: '',
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }
}

final liveFeedControllerProvider =
    StateNotifierProvider<LiveFeedController, LiveFeedState>((ref) {
  return LiveFeedController(ref);
});
