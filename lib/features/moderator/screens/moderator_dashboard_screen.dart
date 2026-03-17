import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/session_provider.dart';

class ModeratorDashboardScreen extends ConsumerWidget {
  const ModeratorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderator Dashboard'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${session.moderatorRole ?? 'Moderator'} · ${session.moderatorGatheringPlace ?? 'Unknown Place'}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Text('Action Required Queue', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const ListTile(
            title: Text('Potential Harassment in Chat ID #882'),
            subtitle: Text('Review: Keep / Delete / Ban'),
          ),
          const ListTile(
            title: Text('Marketplace listing flagged by AI'),
            subtitle: Text('Review wholesome compliance'),
          ),
        ],
      ),
    );
  }
}
