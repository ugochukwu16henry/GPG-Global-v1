import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/session_provider.dart';
import '../providers/mock_data_provider.dart';
import '../widgets/live_events_and_marketplace_demo.dart';
import '../widgets/video_feed_card.dart';

class UserAppShellScreen extends ConsumerStatefulWidget {
  const UserAppShellScreen({super.key});

  @override
  ConsumerState<UserAppShellScreen> createState() => _UserAppShellScreenState();
}

class _UserAppShellScreenState extends ConsumerState<UserAppShellScreen> {
  int _index = 0;

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
          NavigationDestination(icon: Icon(Icons.video_collection_rounded), label: 'Reels'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _reelsPage() {
    final items = ref.watch(gatheringFeedProvider).where((item) => item.isVideo).toList(growable: false);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const LiveEventsAndMarketplaceDemo();
        }
        return VideoFeedCard(item: items[index - 1]);
      },
    );
  }
}

class _ChatPage extends StatelessWidget {
  const _ChatPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.lock_rounded),
          title: Text('Encrypted Mission Peer Chat'),
          subtitle: Text('Secure chat with wholesome guardrails enabled.'),
        ),
        ListTile(
          leading: Icon(Icons.groups_rounded),
          title: Text('Gathering Place Group Chat'),
          subtitle: Text('Threads, typing indicators, and read receipts.'),
        ),
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Profile Settings > My Journey', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        ListTile(
          tileColor: AppColors.primaryNavy.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(isMember ? 'Member' : 'Friend / Seeker'),
          subtitle: const Text('You can update your journey as your life changes.'),
          trailing: Switch(
            value: isMember,
            onChanged: (value) {
              if (value && !isMember) {
                ref.read(sessionControllerProvider.notifier).convertFriendToMember();
                final message = ref.read(sessionControllerProvider).statusMessage;
                if (message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
      ],
    );
  }
}
