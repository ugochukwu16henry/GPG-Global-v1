import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User pathway status: Connect (PathwayConnect) or Degree (degree program).
enum PathwayStatus { connect, degree }

enum RelationshipStatus { single, married }

enum Gender { male, female }

enum VisibilityLevel { everyone, connections, onlyMe }

/// Mission/Pathway status for profile card.
class ProfileState {
  const ProfileState({
    this.displayName = 'Alex',
    this.profilePictureUrl,
    this.bio = 'My testimony: Jesus Christ guides my goals and growth.',
    this.country = 'Nigeria',
    this.state = 'Lagos',
    this.lga = 'Ikeja',
    this.birthday,
    this.relationshipStatus = RelationshipStatus.single,
    this.gender = Gender.male,
    this.isPathwayConnect = true,
    this.isDegree = false,
    this.isAlumni = false,
    this.academicFocus = 'Software Development',
    this.safeSearchFemaleOnly = false,
    this.safeSearchVerifiedMembersOnly = true,
    this.allowsBirthdayBroadcast = true,
    this.missionName = 'Nigeria Lagos Mission',
    this.servedMission = true,
    this.memberStatusLabel = 'Member',
    this.pathwayStatus = PathwayStatus.connect,
    this.pathwayStep = 'PathwayConnect · Semester 2',
    this.visibilityByField = const {
      'age': VisibilityLevel.connections,
      'phone': VisibilityLevel.onlyMe,
      'bloodGroup': VisibilityLevel.onlyMe,
      'genotype': VisibilityLevel.onlyMe,
    },
  });

  final String displayName;
  final String? profilePictureUrl;
  final String bio;
  final String country;
  final String state;
  final String lga;
  final DateTime? birthday;
  final RelationshipStatus relationshipStatus;
  final Gender gender;
  final bool isPathwayConnect;
  final bool isDegree;
  final bool isAlumni;
  final String academicFocus;
  final bool safeSearchFemaleOnly;
  final bool safeSearchVerifiedMembersOnly;
  final bool allowsBirthdayBroadcast;
  final String missionName;
  final bool servedMission;
  final String memberStatusLabel;
  final PathwayStatus pathwayStatus;
  final String pathwayStep;
  final Map<String, VisibilityLevel> visibilityByField;

  int? get age {
    if (birthday == null) {
      return null;
    }
    final now = DateTime.now();
    var years = now.year - birthday!.year;
    final hadBirthday =
        now.month > birthday!.month || (now.month == birthday!.month && now.day >= birthday!.day);
    if (!hadBirthday) {
      years -= 1;
    }
    return years;
  }

  ProfileState copyWith({
    String? displayName,
    String? profilePictureUrl,
    String? bio,
    String? country,
    String? state,
    String? lga,
    DateTime? birthday,
    RelationshipStatus? relationshipStatus,
    Gender? gender,
    bool? isPathwayConnect,
    bool? isDegree,
    bool? isAlumni,
    String? academicFocus,
    bool? safeSearchFemaleOnly,
    bool? safeSearchVerifiedMembersOnly,
    bool? allowsBirthdayBroadcast,
    String? missionName,
    bool? servedMission,
    String? memberStatusLabel,
    PathwayStatus? pathwayStatus,
    String? pathwayStep,
    Map<String, VisibilityLevel>? visibilityByField,
  }) {
    return ProfileState(
      displayName: displayName ?? this.displayName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      state: state ?? this.state,
      lga: lga ?? this.lga,
      birthday: birthday ?? this.birthday,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      gender: gender ?? this.gender,
      isPathwayConnect: isPathwayConnect ?? this.isPathwayConnect,
      isDegree: isDegree ?? this.isDegree,
      isAlumni: isAlumni ?? this.isAlumni,
      academicFocus: academicFocus ?? this.academicFocus,
      safeSearchFemaleOnly: safeSearchFemaleOnly ?? this.safeSearchFemaleOnly,
      safeSearchVerifiedMembersOnly:
          safeSearchVerifiedMembersOnly ?? this.safeSearchVerifiedMembersOnly,
      allowsBirthdayBroadcast: allowsBirthdayBroadcast ?? this.allowsBirthdayBroadcast,
      missionName: missionName ?? this.missionName,
      servedMission: servedMission ?? this.servedMission,
      memberStatusLabel: memberStatusLabel ?? this.memberStatusLabel,
      pathwayStatus: pathwayStatus ?? this.pathwayStatus,
      pathwayStep: pathwayStep ?? this.pathwayStep,
      visibilityByField: visibilityByField ?? this.visibilityByField,
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

  void setVisibility(String fieldKey, VisibilityLevel level) {
    state = state.copyWith(
      visibilityByField: {
        ...state.visibilityByField,
        fieldKey: level,
      },
    );
  }

  void setSafetyMode({bool? femaleOnly, bool? verifiedMembersOnly}) {
    state = state.copyWith(
      safeSearchFemaleOnly: femaleOnly ?? state.safeSearchFemaleOnly,
      safeSearchVerifiedMembersOnly:
          verifiedMembersOnly ?? state.safeSearchVerifiedMembersOnly,
    );
  }

  void setPathwayJourney({
    bool? isPathwayConnect,
    bool? isDegree,
    bool? isAlumni,
    String? academicFocus,
  }) {
    state = state.copyWith(
      isPathwayConnect: isPathwayConnect ?? state.isPathwayConnect,
      isDegree: isDegree ?? state.isDegree,
      isAlumni: isAlumni ?? state.isAlumni,
      academicFocus: academicFocus ?? state.academicFocus,
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

