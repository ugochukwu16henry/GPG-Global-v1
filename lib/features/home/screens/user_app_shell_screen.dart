import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/session_provider.dart';
import '../../backend/providers/backend_live_providers.dart';
import '../../storage/services/storage_service.dart';
import '../../storage/widgets/file_upload_button.dart';
import '../providers/live_feed_provider.dart';
import 'privacy_safety_screen.dart';
import '../widgets/profile_card.dart';
import '../widgets/video_feed_card.dart';

class UserAppShellScreen extends ConsumerStatefulWidget {
  const UserAppShellScreen({super.key});

  @override
  ConsumerState<UserAppShellScreen> createState() => _UserAppShellScreenState();
}

class _UserAppShellScreenState extends ConsumerState<UserAppShellScreen> {
  int _index = 0;
  late final TextEditingController _postBodyController;

  @override
  void initState() {
    super.initState();
    _postBodyController = TextEditingController();
    Future.microtask(() {
      ref.read(liveFeedControllerProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _postBodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);

    final pages = [
      _reelsPage(),
      const _ChatPage(),
      _SettingsPage(session: session),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPG Community'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(backendUserIdProvider.notifier).state = 'anonymous';
              ref.read(sessionControllerProvider.notifier).signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.video_collection_rounded), label: 'Reels'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
          NavigationDestination(
              icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _reelsPage() {
    final feedState = ref.watch(liveFeedControllerProvider);
    final feedController = ref.read(liveFeedControllerProvider.notifier);
    final items = feedState.items;
    final userId = ref.watch(backendUserIdProvider);
    final gateway = ref.watch(backendGatewayProvider);
    final storageService = ref.watch(storageServiceProvider);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: (items.isEmpty ? 1 : items.length) + 2,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share a photo or video with the Gathering Place',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _postBodyController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText:
                        'Write a caption, testimony, update, or skill showcase...',
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (storageService != null) ...[
                      FileUploadButton(
                        storageService: storageService,
                        bucket: StorageBucket.media,
                        label: 'Upload Picture',
                        icon: Icons.photo_library_outlined,
                        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
                        onUploaded: (result) {
                          feedController.setUploadedMedia(
                            path: result.path,
                            previewUrl: result.publicOrSignedUrl,
                          );
                        },
                      ),
                      FileUploadButton(
                        storageService: storageService,
                        bucket: StorageBucket.media,
                        label: 'Upload Video',
                        icon: Icons.video_library_outlined,
                        allowedExtensions: const ['mp4', 'mov', 'm4v', 'webm'],
                        onUploaded: (result) {
                          feedController.setUploadedMedia(
                            path: result.path,
                            previewUrl: result.publicOrSignedUrl,
                          );
                        },
                      ),
                    ],
                    FilledButton(
                      onPressed: feedState.isLoading
                          ? null
                          : () async {
                              await feedController.publishPost(
                                textBody: _postBodyController.text,
                              );
                              if (mounted) {
                                _postBodyController.clear();
                              }
                            },
                      child: const Text('Publish Post'),
                    ),
                    FilledButton.tonal(
                      onPressed: feedState.isLoading
                          ? null
                          : () => feedController.refresh(),
                      child: const Text('Refresh Feed'),
                    ),
                  ],
                ),
                if ((feedState.lastUploadedMediaPreviewUrl ?? '')
                    .isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Media attached from storage path: ${feedState.lastUploadedMediaPath}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
                if (feedState.error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    feedState.error!,
                    style: const TextStyle(color: AppColors.warmCrimson),
                  ),
                ],
              ],
            ),
          );
        }
        if (index == 1) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: gateway.homeTalentBanners(userId: userId, limit: 5),
            builder: (context, snapshot) {
              final data = snapshot.data ?? const <Map<String, dynamic>>[];
              if (data.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.pathwayAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('New Talent in Your Country',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    ...data.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '• ${entry['vendorName']} · ${entry['category'] ?? 'General Talent'}',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
                'No posts yet. Upload a picture or video to get the feed started.'),
          );
        }
        return VideoFeedCard(item: items[index - 2]);
      },
    );
  }
}

class _ChatPage extends ConsumerStatefulWidget {
  const _ChatPage();

  @override
  ConsumerState<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<_ChatPage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guardian = ref.watch(silentGuardianControllerProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ListTile(
          leading: Icon(Icons.lock_rounded),
          title: Text('Encrypted Mission Peer Chat'),
          subtitle: Text('Secure chat with wholesome guardrails enabled.'),
        ),
        const ListTile(
          leading: Icon(Icons.groups_rounded),
          title: Text('Gathering Place Group Chat'),
          subtitle: Text('Threads, typing indicators, and read receipts.'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Message Composer',
            hintText:
                'Write a respectful message to test wholesome guardrails...',
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonal(
              onPressed: guardian.isLoading
                  ? null
                  : () => ref
                      .read(silentGuardianControllerProvider.notifier)
                      .guardAndSend(
                        roomId: 'global-community-room',
                        body: _messageController.text.trim(),
                      ),
              child: const Text('Send Through Guardrails'),
            ),
          ],
        ),
        if (guardian.lastNudge != null) ...[
          const SizedBox(height: 8),
          Text('Guardrail nudge: ${guardian.lastNudge}'),
        ],
        if (guardian.error != null) ...[
          const SizedBox(height: 8),
          Text(
            guardian.error!,
            style: const TextStyle(color: AppColors.warmCrimson),
          ),
        ],
      ],
    );
  }
}

class _SettingsPage extends ConsumerWidget {
  const _SettingsPage({required this.session});

  final SessionState session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMember = session.identity == CommunityIdentity.member;
    final userId = ref.watch(backendUserIdProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ProfileCard(),
        const SizedBox(height: 16),
        const Text('Profile Settings > My Journey',
            style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        ListTile(
          tileColor: AppColors.primaryNavy.withValues(alpha: 0.05),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(isMember ? 'Member' : 'Friend / Seeker'),
          subtitle:
              const Text('You can update your journey as your life changes.'),
          trailing: Switch(
            value: isMember,
            onChanged: (value) {
              if (value && !isMember) {
                ref
                    .read(sessionControllerProvider.notifier)
                    .convertFriendToMember();
                final message =
                    ref.read(sessionControllerProvider).statusMessage;
                if (message != null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                }
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Marketplace Rules\n- Friends: paid listing + ID/phone verification\n- Members: paid listing (possible stewardship discount) + leader vouch option',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pushNamed('/vendor-studio'),
          child: const Text('Open Vendor Studio / Boost My Talent'),
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrivacySafetyScreen()),
          ),
          child: const Text('Open Privacy & Safety'),
        ),
        const SizedBox(height: 8),
        Text(
          'Authenticated user ID: $userId',
          style: const TextStyle(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
