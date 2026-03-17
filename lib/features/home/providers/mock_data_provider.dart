import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User pathway status: Connect (PathwayConnect) or Degree (degree program).
enum PathwayStatus { connect, degree }

/// Mission/Pathway status for profile card.
class ProfileState {
  const ProfileState({
    this.displayName = 'Alex',
    this.missionName = 'Nigeria Lagos Mission',
    this.pathwayStatus = PathwayStatus.connect,
    this.pathwayStep = 'PathwayConnect · Semester 2',
  });

  final String displayName;
  final String missionName;
  final PathwayStatus pathwayStatus;
  final String pathwayStep;

  ProfileState copyWith({
    String? displayName,
    String? missionName,
    PathwayStatus? pathwayStatus,
    String? pathwayStep,
  }) {
    return ProfileState(
      displayName: displayName ?? this.displayName,
      missionName: missionName ?? this.missionName,
      pathwayStatus: pathwayStatus ?? this.pathwayStatus,
      pathwayStep: pathwayStep ?? this.pathwayStep,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  void toggleStatus() {
    state = state.copyWith(
      pathwayStatus: state.pathwayStatus == PathwayStatus.connect
          ? PathwayStatus.degree
          : PathwayStatus.connect,
      pathwayStep: state.pathwayStatus == PathwayStatus.connect
          ? 'Degree Program · Software Development'
          : 'PathwayConnect · Semester 2',
    );
  }
}

/// Pathway progress percentage (0–100).
final pathwayProgressProvider = StateProvider<int>((ref) => 68);

/// Single feed item (video or post).
class FeedItem {
  const FeedItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.isVideo = true,
    this.avatarUrl,
  });

  final String id;
  final String title;
  final String? subtitle;
  final bool isVideo;
  final String? avatarUrl;
}

final gatheringFeedProvider = Provider<List<FeedItem>>((ref) {
  return const [
    FeedItem(
      id: '1',
      title: 'Welcome to GPG Gathering',
      subtitle: 'BYU-Pathway · 2h ago',
      isVideo: true,
    ),
    FeedItem(
      id: '2',
      title: 'Study group highlights',
      subtitle: 'Lagos YSA · 5h ago',
      isVideo: true,
    ),
    FeedItem(
      id: '3',
      title: 'Mission reunion recap',
      subtitle: 'Nigeria Lagos Mission · 1d ago',
      isVideo: true,
    ),
    FeedItem(
      id: '4',
      title: 'Marketplace success story',
      subtitle: 'Community · 2d ago',
      isVideo: false,
    ),
  ];
});
