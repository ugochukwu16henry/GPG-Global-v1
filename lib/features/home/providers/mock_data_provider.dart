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

/// --- Live demo integrations -------------------------------------------------

/// Simple live event (birthday, chat, or other notification).
class LiveEvent {
  const LiveEvent({
    required this.id,
    required this.type,
    required this.message,
    required this.timestampLabel,
  });

  final String id;
  final String type; // e.g. "Birthday", "Chat"
  final String message;
  final String timestampLabel;
}

/// Mock stream of latest live events for the home screen ticker.
final liveEventsProvider = StateProvider<List<LiveEvent>>((ref) {
  return const [
    LiveEvent(
      id: 'e1',
      type: 'Birthday',
      message: 'It’s Mercy’s birthday in Lagos Study Group 🎉',
      timestampLabel: 'Just now',
    ),
    LiveEvent(
      id: 'e2',
      type: 'Chat',
      message: 'New message in Nigeria Lagos Mission Reunion',
      timestampLabel: '2 min ago',
    ),
    LiveEvent(
      id: 'e3',
      type: 'Milestone',
      message: 'Samuel moved from Connect → Degree in Software Dev',
      timestampLabel: '10 min ago',
    ),
  ];
});

/// Marketplace listing used for the filter demo.
class MarketplaceListing {
  const MarketplaceListing({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
  });

  final String id;
  final String title;
  final String category; // e.g. "Tech", "Tutoring"
  final String location;
}

final _allMarketplaceListings = [
  const MarketplaceListing(
    id: 'm1',
    title: 'Junior Flutter Developer (Remote)',
    category: 'Tech',
    location: 'Lagos',
  ),
  const MarketplaceListing(
    id: 'm2',
    title: 'Pathway Math Tutor',
    category: 'Tutoring',
    location: 'Salt Lake City',
  ),
  const MarketplaceListing(
    id: 'm3',
    title: 'Graphic Designer · Portfolio help',
    category: 'Creative',
    location: 'Accra',
  ),
  const MarketplaceListing(
    id: 'm4',
    title: 'Return Missionary Web Developer',
    category: 'Tech',
    location: 'Nairobi',
  ),
];

/// Selected marketplace category for the demo filter pill row.
final selectedMarketplaceCategoryProvider = StateProvider<String?>((ref) => null);

/// Filtered marketplace listings based on selected category.
final filteredMarketplaceListingsProvider = Provider<List<MarketplaceListing>>((ref) {
  final selected = ref.watch(selectedMarketplaceCategoryProvider);
  if (selected == null) {
    return _allMarketplaceListings;
  }
  return _allMarketplaceListings.where((e) => e.category == selected).toList();
});

