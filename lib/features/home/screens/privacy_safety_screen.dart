import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../backend/providers/boundary_providers.dart';

class PrivacySafetyScreen extends ConsumerStatefulWidget {
  const PrivacySafetyScreen({super.key});

  @override
  ConsumerState<PrivacySafetyScreen> createState() => _PrivacySafetyScreenState();
}

class _PrivacySafetyScreenState extends ConsumerState<PrivacySafetyScreen> {
  late final TextEditingController _targetUserIdController;
  String _blockReason = 'HARASSMENT';

  @override
  void initState() {
    super.initState();
    _targetUserIdController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(boundaryControllerProvider.notifier).refreshBlockedAccounts();
    });
  }

  @override
  void dispose() {
    _targetUserIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(boundaryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings · Privacy & Safety')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Managed Block List',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _targetUserIdController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              labelText: 'Target User ID',
              hintText: 'u1002',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _blockReason,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'SPAM', child: Text('Spam')),
                    DropdownMenuItem(value: 'HARASSMENT', child: Text('Harassment')),
                    DropdownMenuItem(value: 'INAPPROPRIATE_CONTENT', child: Text('Inappropriate Content')),
                    DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _blockReason = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: state.isLoading
                    ? null
                    : () {
                        final target = _targetUserIdController.text.trim();
                        if (target.isEmpty) return;
                        ref.read(boundaryControllerProvider.notifier).blockUser(
                              blockedId: target,
                              reasonCode: _blockReason,
                            );
                      },
                child: const Text('Block User'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.message != null)
            Text(state.message!, style: const TextStyle(color: AppColors.stewardshipGreen)),
          if (state.error != null)
            Text(state.error!, style: const TextStyle(color: AppColors.warmCrimson)),
          const SizedBox(height: 8),
          if (state.isLoading) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          ...state.blockedAccounts.map(
            (account) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.pathwayAmber.withValues(alpha: 0.3),
                    child: Text(
                      account.displayName.isEmpty ? '?' : account.displayName[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.primaryNavy),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(account.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          'Blocked at ${account.blockedAt}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: state.isLoading
                        ? null
                        : () => ref.read(boundaryControllerProvider.notifier).unblockUser(
                              blockedId: account.userId,
                            ),
                    child: const Text('Unblock'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () {
                  final target = _targetUserIdController.text.trim();
                  if (target.isEmpty) return;
                  ref.read(boundaryControllerProvider.notifier).muteUser(mutedId: target);
                },
                child: const Text('Mute'),
              ),
              FilledButton.tonal(
                onPressed: () {
                  final target = _targetUserIdController.text.trim();
                  if (target.isEmpty) return;
                  ref.read(boundaryControllerProvider.notifier).reportUser(
                        reportedId: target,
                        reasonCode: 'HARASSMENT',
                        detail: 'Reported from Privacy & Safety dashboard',
                      );
                },
                child: const Text('Report'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
