import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/theme_mode_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/session_provider.dart';
import '../../backend/providers/backend_live_providers.dart';
import '../../storage/services/storage_service.dart';
import '../../storage/widgets/file_upload_button.dart';
import '../providers/live_feed_provider.dart';
import '../providers/mock_data_provider.dart';
import '../widgets/custom_nav_bar.dart';
import '../widgets/desktop_left_sidebar.dart';
import '../widgets/g_nexus_logo.dart';
import '../widgets/gathering_place_hierarchy_panel.dart';
import '../widgets/glass_card.dart';
import '../widgets/pathway_progress_tracker.dart';
import '../widgets/profile_card.dart';
import '../widgets/right_context_sidebar.dart';
import '../widgets/video_feed_card.dart';
import 'marketplace_talent_detail_screen.dart';
import 'privacy_safety_screen.dart';

class UserCommandCenterScreen extends ConsumerStatefulWidget {
  const UserCommandCenterScreen({super.key});

  @override
  ConsumerState<UserCommandCenterScreen> createState() =>
      _UserCommandCenterScreenState();
}

enum _SurfaceTab { home, peers, marketplace, academy, settings }

class _UserCommandCenterScreenState
    extends ConsumerState<UserCommandCenterScreen> {
  _SurfaceTab _tab = _SurfaceTab.home;
  late final TextEditingController _postBodyController;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _postBodyController = TextEditingController();
    _messageController = TextEditingController();
    Future.microtask(() {
      ref.read(liveFeedControllerProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _postBodyController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  CommandCenterTab get _desktopTab => switch (_tab) {
        _SurfaceTab.home => CommandCenterTab.home,
        _SurfaceTab.peers => CommandCenterTab.peers,
        _SurfaceTab.marketplace => CommandCenterTab.marketplace,
        _SurfaceTab.academy => CommandCenterTab.academy,
        _SurfaceTab.settings => CommandCenterTab.settings,
      };

  void _setMobileTab(int index) {
    setState(() {
      _tab = _SurfaceTab.values[index];
    });
  }

  void _signOut() {
    ref.read(backendUserIdProvider.notifier).state = 'anonymous';
    ref.read(sessionControllerProvider.notifier).signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  Future<void> _publishPost() async {
    HapticFeedback.mediumImpact();
    await ref.read(liveFeedControllerProvider.notifier).publishPost(
          textBody: _postBodyController.text,
        );
    if (mounted) {
      _postBodyController.clear();
    }
  }

  Future<void> _sendGuardedMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final sent =
        await ref.read(silentGuardianControllerProvider.notifier).guardAndSend(
              roomId: 'global-community-room',
              body: _messageController.text.trim(),
            );
    if (sent && mounted) {
      HapticFeedback.lightImpact();
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 768;
    return isDesktop ? _buildDesktop() : _buildMobile();
  }

  Widget _buildDesktop() {
    final session = ref.watch(sessionControllerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 260,
                    child: DesktopLeftSidebar(
                      selectedTab: _desktopTab,
                      onTabSelected: (tab) {
                        setState(() {
                          _tab = switch (tab) {
                            CommandCenterTab.home => _SurfaceTab.home,
                            CommandCenterTab.peers => _SurfaceTab.peers,
                            CommandCenterTab.marketplace =>
                              _SurfaceTab.marketplace,
                            CommandCenterTab.academy => _SurfaceTab.academy,
                            CommandCenterTab.settings => _SurfaceTab.settings,
                          };
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _DesktopTopBar(
                          session: session,
                          themeMode: themeMode,
                          onToggleTheme: () {
                            ref.read(themeModeProvider.notifier).state =
                                themeMode == ThemeMode.dark
                                    ? ThemeMode.light
                                    : ThemeMode.dark;
                          },
                          onSignOut: _signOut,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _DesktopCenterPane(
                              key: ValueKey(_tab),
                              tab: _tab,
                              postBodyController: _postBodyController,
                              messageController: _messageController,
                              onPublishPost: _publishPost,
                              onSendMessage: _sendGuardedMessage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  const SizedBox(
                    width: 300,
                    child: SingleChildScrollView(child: RightContextSidebar()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobile() {
    final session = ref.watch(sessionControllerProvider);
    final profile = ref.watch(profileProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 132,
            backgroundColor: AppColors.surfaceWhite,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                const GNexusLogo(size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    profile.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ref.read(themeModeProvider.notifier).state =
                      themeMode == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                },
                icon: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                ),
              ),
              IconButton(
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Thumb-first GPG Command Center',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${session.identity == CommunityIdentity.member ? 'Member' : 'Friend / Seeker'} · ${profile.state}, ${profile.country}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            sliver: SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _MobileTabBody(
                  key: ValueKey(_tab),
                  tab: _tab,
                  postBodyController: _postBodyController,
                  messageController: _messageController,
                  onPublishPost: _publishPost,
                  onSendMessage: _sendGuardedMessage,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: CustomNavBar(
            currentIndex: _tab.index,
            onTap: _setMobileTab,
            marketplaceIndex: 2,
            elevateMarketplace: true,
          ),
        ),
      ),
    );
  }
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar({
    required this.session,
    required this.themeMode,
    required this.onToggleTheme,
    required this.onSignOut,
  });

  final SessionState session;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GPG Command Center',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                session.identity == CommunityIdentity.member
                    ? 'Faith, learning, and trusted opportunity in one workspace.'
                    : 'Discover peers, learning, and community at your own pace.',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: onToggleTheme,
          icon: Icon(
            themeMode == ThemeMode.dark
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
          ),
          label: const Text('Theme'),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
        ),
        const SizedBox(width: 10),
        FilledButton.tonalIcon(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign Out'),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
        ),
      ],
    );
  }
}

class _DesktopCenterPane extends ConsumerWidget {
  const _DesktopCenterPane({
    super.key,
    required this.tab,
    required this.postBodyController,
    required this.messageController,
    required this.onPublishPost,
    required this.onSendMessage,
  });

  final _SurfaceTab tab;
  final TextEditingController postBodyController;
  final TextEditingController messageController;
  final Future<void> Function() onPublishPost;
  final Future<void> Function() onSendMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (tab) {
      _SurfaceTab.home => _HomePane(
          postBodyController: postBodyController,
          onPublishPost: onPublishPost,
          isDesktop: true,
        ),
      _SurfaceTab.peers => _PeersPane(
          messageController: messageController,
          onSendMessage: onSendMessage,
        ),
      _SurfaceTab.marketplace => const _MarketplacePane(),
      _SurfaceTab.academy => const _AcademyPane(),
      _SurfaceTab.settings => const _SettingsPane(),
    };
  }
}

class _MobileTabBody extends ConsumerWidget {
  const _MobileTabBody({
    super.key,
    required this.tab,
    required this.postBodyController,
    required this.messageController,
    required this.onPublishPost,
    required this.onSendMessage,
  });

  final _SurfaceTab tab;
  final TextEditingController postBodyController;
  final TextEditingController messageController;
  final Future<void> Function() onPublishPost;
  final Future<void> Function() onSendMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (tab) {
      _SurfaceTab.home => _HomePane(
          postBodyController: postBodyController,
          onPublishPost: onPublishPost,
          isDesktop: false,
        ),
      _SurfaceTab.peers => _PeersPane(
          messageController: messageController,
          onSendMessage: onSendMessage,
        ),
      _SurfaceTab.marketplace => const _MarketplacePane(),
      _SurfaceTab.academy => const _AcademyPane(),
      _SurfaceTab.settings => const _SettingsPane(),
    };
  }
}

class _HomePane extends ConsumerWidget {
  const _HomePane({
    required this.postBodyController,
    required this.onPublishPost,
    required this.isDesktop,
  });

  final TextEditingController postBodyController;
  final Future<void> Function() onPublishPost;
  final bool isDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(liveFeedControllerProvider);
    final storageService = ref.watch(storageServiceProvider);
    final items = feedState.items;

    final topCards = isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(flex: 6, child: ProfileCard()),
              SizedBox(width: 16),
              Expanded(flex: 3, child: PathwayProgressTracker()),
              SizedBox(width: 16),
              Expanded(flex: 4, child: _CommunityPulseCard()),
            ],
          )
        : const Column(
            children: [
              ProfileCard(),
              SizedBox(height: 12),
              PathwayProgressTracker(),
            ],
          );

    final featuredItem = items.isEmpty ? null : items.first;
    final remainingItems =
        items.length <= 1 ? const <FeedItem>[] : items.sublist(1);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topCards,
          const SizedBox(height: 20),
          if (isDesktop)
            const _SectionHeader(
              eyebrow: 'Publisher Desk',
              title: 'Share Something Uplifting',
              subtitle:
                  'Post updates, testimonies, and opportunities into your gathering feed.',
            ),
          if (isDesktop) const SizedBox(height: 10),
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post to your Gathering Place',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Share edge-to-edge videos, images, testimonies, and updates.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: postBodyController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Post Caption',
                    hintText: 'Write a testimony, update, or skill showcase...',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (storageService != null)
                      FileUploadButton(
                        storageService: storageService,
                        bucket: StorageBucket.media,
                        label: 'Upload Picture',
                        icon: Icons.photo_library_outlined,
                        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
                        onUploaded: (result) {
                          ref
                              .read(liveFeedControllerProvider.notifier)
                              .setUploadedMedia(
                                path: result.path,
                                previewUrl: result.publicOrSignedUrl,
                              );
                        },
                      ),
                    if (storageService != null)
                      FileUploadButton(
                        storageService: storageService,
                        bucket: StorageBucket.media,
                        label: 'Upload Video',
                        icon: Icons.video_library_outlined,
                        allowedExtensions: const ['mp4', 'mov', 'm4v', 'webm'],
                        onUploaded: (result) {
                          ref
                              .read(liveFeedControllerProvider.notifier)
                              .setUploadedMedia(
                                path: result.path,
                                previewUrl: result.publicOrSignedUrl,
                              );
                        },
                      ),
                    FilledButton(
                      onPressed: feedState.isLoading ? null : onPublishPost,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(160, 48),
                      ),
                      child: const Text('Publish Post'),
                    ),
                    FilledButton.tonal(
                      onPressed: feedState.isLoading
                          ? null
                          : () => ref
                              .read(liveFeedControllerProvider.notifier)
                              .refresh(),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(160, 48),
                      ),
                      child: const Text('Refresh Feed'),
                    ),
                  ],
                ),
                if ((feedState.lastUploadedMediaPath ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Attached media path: ${feedState.lastUploadedMediaPath}',
                    style: const TextStyle(color: AppColors.textMuted),
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
          ),
          const SizedBox(height: 20),
          if (items.isEmpty)
            const GlassCard(
              borderRadius: 16,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                    'No posts yet. Upload a picture or video to get the feed started.'),
              ),
            )
          else if (isDesktop)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionHeader(
                  eyebrow: 'Editorial Feed',
                  title: 'Featured + Live Community Stream',
                  subtitle:
                      'Curated spotlight first, then a staggered masonry of live posts.',
                ),
                const SizedBox(height: 12),
                if (featuredItem != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: VideoFeedCard(
                      item: featuredItem,
                      onHireTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MarketplaceTalentDetailScreen(
                              vendor: {
                                'userId': featuredItem.ownerUserId,
                                'vendorName':
                                    featuredItem.subtitle ?? featuredItem.title,
                                'category':
                                    featuredItem.moderationTags.isNotEmpty
                                        ? featuredItem.moderationTags.first
                                        : 'General',
                              },
                              entryContext: 'Featured Feed',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (remainingItems.isNotEmpty)
                  _DesktopMasonryFeed(items: remainingItems),
              ],
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: VideoFeedCard(
                  item: item,
                  onHireTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MarketplaceTalentDetailScreen(
                          vendor: {
                            'userId': item.ownerUserId,
                            'vendorName': item.subtitle ?? item.title,
                            'category': item.moderationTags.isNotEmpty
                                ? item.moderationTags.first
                                : 'General',
                          },
                          entryContext: 'Home Feed',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DesktopMasonryFeed extends StatelessWidget {
  const _DesktopMasonryFeed({required this.items});

  final List<FeedItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth > 1100 ? 3 : 2;
        final columns = List.generate(columnCount, (_) => <Widget>[]);
        final gutter = columnCount == 3 ? 20.0 : 16.0;

        for (var index = 0; index < items.length; index++) {
          final item = items[index];
          columns[index % columnCount].add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: VideoFeedCard(
                item: item,
                onHireTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MarketplaceTalentDetailScreen(
                        vendor: {
                          'userId': item.ownerUserId,
                          'vendorName': item.subtitle ?? item.title,
                          'category': item.moderationTags.isNotEmpty
                              ? item.moderationTags.first
                              : 'General',
                        },
                        entryContext: 'Home Feed',
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(columnCount * 2 - 1, (index) {
            if (index.isOdd) {
              return SizedBox(width: gutter);
            }
            final columnIndex = index ~/ 2;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    top: columnIndex == 0 ? 0 : columnIndex * 18),
                child: Column(children: columns[columnIndex]),
              ),
            );
          }),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
            color: AppColors.pathwayAmber,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryNavy,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _CommunityPulseCard extends ConsumerWidget {
  const _CommunityPulseCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(liveFeedControllerProvider);
    final profile = ref.watch(profileProvider);

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Pulse',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 10),
          _statRow('Location', '${profile.state}, ${profile.country}'),
          _statRow('Pathway', profile.pathwayStep),
          _statRow('Feed Items', '${feedState.items.length} live posts'),
          _statRow('Account', profile.memberStatusLabel),
        ],
      ),
    );
  }

  Widget _statRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _PeersPane extends ConsumerWidget {
  const _PeersPane({
    required this.messageController,
    required this.onSendMessage,
  });

  final TextEditingController messageController;
  final Future<void> Function() onSendMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guardian = ref.watch(silentGuardianControllerProvider);
    final previews = ref.watch(missionPeerChatPreviewProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peers & Study Groups',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Secure messaging with wholesome guardrails and community prompts.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Message Composer',
                    hintText: 'Write a respectful message to your peers...',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: guardian.isLoading ? null : onSendMessage,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(180, 48),
                  ),
                  child: const Text('Send Message'),
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
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Chat Shortcuts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 10),
                ...previews.take(4).map(
                      (message) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                            child: Icon(Icons.chat_bubble_outline_rounded)),
                        title: Text(message.senderName),
                        subtitle: Text(
                          message.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const GatheringPlaceHierarchyPanel(),
        ],
      ),
    );
  }
}

class _MarketplacePane extends ConsumerWidget {
  const _MarketplacePane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(backendUserIdProvider);
    final gateway = ref.watch(backendGatewayProvider);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: gateway.marketplaceDirectory(limit: 20),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <Map<String, dynamic>>[];
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marketplace',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Discover trusted talent and manage your own vendor presence.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/vendor-studio'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(220, 48),
                      ),
                      child: const Text('Open Vendor Studio'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Active user: $userId',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const LinearProgressIndicator(),
              if (items.isEmpty &&
                  snapshot.connectionState != ConnectionState.waiting)
                const GlassCard(
                  borderRadius: 16,
                  child: Text(
                      'No marketplace talent is live in your directory yet.'),
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: GlassCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const GNexusLogo(size: 34),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (item['vendorName'] ?? 'Unknown Vendor')
                                      .toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item['category'] ?? 'General'} · ${item['state'] ?? ''}, ${item['country'] ?? ''}',
                                  style: const TextStyle(
                                      color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MarketplaceTalentDetailScreen(
                                    vendor: item,
                                  ),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                                minimumSize: const Size(120, 48)),
                            child: const Text('View'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AcademyPane extends ConsumerWidget {
  const _AcademyPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(pathwayProgressProvider);
    final previews = ref.watch(missionPeerChatPreviewProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Academy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current pathway completion: $progress%',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                const PathwayProgressTracker(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study Group Chat Shortcuts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 10),
                ...previews.take(3).map(
                      (message) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.school_rounded),
                        title: Text(message.senderName),
                        subtitle: Text(message.body),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsPane extends ConsumerWidget {
  const _SettingsPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final isMember = session.identity == CommunityIdentity.member;
    final userId = ref.watch(backendUserIdProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProfileCard(),
          const SizedBox(height: 16),
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(isMember ? 'Member' : 'Friend / Seeker'),
                  subtitle: const Text('Update your journey as life changes.'),
                  trailing: Switch(
                    value: isMember,
                    onChanged: (value) {
                      if (value && !isMember) {
                        ref
                            .read(sessionControllerProvider.notifier)
                            .convertFriendToMember();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.tonal(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/vendor-studio'),
                  style:
                      FilledButton.styleFrom(minimumSize: const Size(220, 48)),
                  child: const Text('Open Vendor Studio'),
                ),
                const SizedBox(height: 10),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PrivacySafetyScreen()),
                  ),
                  style:
                      FilledButton.styleFrom(minimumSize: const Size(220, 48)),
                  child: const Text('Open Privacy & Safety'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Authenticated user ID: $userId',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
