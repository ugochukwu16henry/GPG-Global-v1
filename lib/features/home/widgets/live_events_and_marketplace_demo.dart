import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/branding/sonic_identity_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../backend/providers/backend_live_providers.dart';
import '../../backend/providers/boundary_providers.dart';
import '../screens/marketplace_success_screen.dart';
import '../providers/mock_data_provider.dart';
import 'g_nexus_logo.dart';
import 'glass_card.dart';

/// Small demo integration strip:
/// - horizontally scrollable live events (birthday/chat)
/// - marketplace filter chips + filtered mock listings
class LiveEventsAndMarketplaceDemo extends ConsumerWidget {
  const LiveEventsAndMarketplaceDemo({super.key});

  Future<void> _launchCheckout(BuildContext context, String? checkoutUrl) async {
    if (checkoutUrl == null || checkoutUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout URL not available yet.')),
      );
      return;
    }
    final uri = Uri.tryParse(checkoutUrl);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open checkout URL.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = TextEditingController();
    final liveEvents = ref.watch(liveEventsProvider);
    final listings = ref.watch(filteredMarketplaceListingsProvider);
    final previewMessages = ref.watch(missionPeerChatPreviewProvider);
    final selectedCategory = ref.watch(selectedMarketplaceCategoryProvider);
    final backendState = ref.watch(backendDemoControllerProvider);
    final guardian = ref.watch(silentGuardianControllerProvider);
    final realtimeRedFlag = ref.watch(backendRedFlagStreamProvider);
    const sonicIdentity = SonicIdentityService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live activity · Grow your faith · Connect with your peers',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: liveEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final event = liveEvents[index];
                    final color = switch (event.type) {
                      'Birthday' => AppColors.pathwayAmber,
                      'Chat' => AppColors.primaryNavy,
                      _ => AppColors.primaryNavy.withValues(alpha: 0.85),
                    };
                    final icon = switch (event.type) {
                      'Birthday' => Icons.cake_rounded,
                      'Chat' => Icons.chat_bubble_rounded,
                      _ => Icons.star_rounded,
                    };
                    final toneType = switch (event.type) {
                      'Birthday' => GpgToneType.dailyScriptureOrBirthday,
                      'Chat' => GpgToneType.messageReceived,
                      _ => GpgToneType.missionPeerFound,
                    };
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 16, color: color),
                          const SizedBox(width: 6),
                          if (event.type == 'Birthday') ...[
                            const GNexusLogo(
                              size: 16,
                              variant: LogoSurfaceVariant.birthdayGlow,
                            ),
                            const SizedBox(width: 6),
                          ],
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  event.message,
                                  style: TextStyle(
                                    fontSize: 11,
                                    height: 1,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textOnSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  event.timestampLabel,
                                  style: TextStyle(
                                    fontSize: 9,
                                    height: 1,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => sonicIdentity.preview(toneType),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.volume_up_rounded,
                                size: 14,
                                color: color,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_horiz,
                              size: 14,
                              color: color,
                            ),
                            onSelected: (value) async {
                              final controller = ref.read(boundaryControllerProvider.notifier);
                              if (value == 'block') {
                                await controller.blockUser(
                                  blockedId: event.id,
                                  reasonCode: 'HARASSMENT',
                                );
                              } else if (value == 'mute') {
                                await controller.muteUser(mutedId: event.id);
                              } else if (value == 'report') {
                                await controller.reportUser(
                                  reportedId: event.id,
                                  reasonCode: 'HARASSMENT',
                                  detail: 'Reported from live event menu',
                                );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'block',
                                child: Text('Block User'),
                              ),
                              PopupMenuItem(
                                value: 'mute',
                                child: Text('Mute User'),
                              ),
                              PopupMenuItem(
                                value: 'report',
                                child: Text('Report User'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Frugal stewardship: birthday and peer data are shown only with user authorization.',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: backendState.isLoading
                        ? null
                        : () => ref
                            .read(backendDemoControllerProvider.notifier)
                            .runMissionSearch('Lagos'),
                    child: const Text('Mission Search (Lagos)'),
                  ),
                  FilledButton.tonal(
                    onPressed: backendState.isLoading
                        ? null
                        : () => ref
                            .read(backendDemoControllerProvider.notifier)
                            .createCheckout(),
                    child: const Text('Create $2 Checkout'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => _launchCheckout(context, backendState.checkoutUrl),
                    child: const Text('Open Checkout'),
                  ),
                  FilledButton.tonal(
                    onPressed: backendState.isLoading
                        ? null
                        : () => ref
                            .read(backendDemoControllerProvider.notifier)
                            .sendModerationProbe(),
                    child: const Text('Send Moderation Probe'),
                  ),
                ],
              ),
              if (backendState.missionSuggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Mission suggestions: ${backendState.missionSuggestions.join(', ')}',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
              if (backendState.peerMatchSummary != null) ...[
                const SizedBox(height: 4),
                Text(
                  backendState.peerMatchSummary!,
                  style: TextStyle(fontSize: 10, color: AppColors.stewardshipGreen),
                ),
              ],
              if (backendState.moderationResult != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Guardrail result: ${backendState.moderationResult}',
                  style: TextStyle(
                    fontSize: 10,
                    color: backendState.moderationResult!.contains('No violation')
                        ? AppColors.stewardshipGreen
                        : AppColors.warmCrimson,
                  ),
                ),
              ],
              if (backendState.error != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Backend error: ${backendState.error}',
                  style: TextStyle(fontSize: 10, color: AppColors.warmCrimson),
                ),
              ],
              realtimeRedFlag.when(
                data: (value) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Control Room alert: $value',
                    style: TextStyle(fontSize: 10, color: AppColors.warmCrimson),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              _chatGuardianComposer(context, ref, messageController, guardian),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marketplace demo filter · Showcase your talent',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildFilterChip(ref, label: 'All', value: null, selected: selectedCategory == null),
                  _buildFilterChip(ref, label: 'Tech', value: 'Tech', selected: selectedCategory == 'Tech'),
                  _buildFilterChip(ref, label: 'Tutoring', value: 'Tutoring', selected: selectedCategory == 'Tutoring'),
                  _buildFilterChip(ref, label: 'Creative', value: 'Creative', selected: selectedCategory == 'Creative'),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                children: listings
                    .map(
                      (listing) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.work_rounded,
                                size: 16,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listing.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textOnSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${listing.category} · ${listing.location}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const MeritBadge(),
                            const SizedBox(width: 4),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_horiz,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                              onSelected: (value) async {
                                final controller = ref.read(boundaryControllerProvider.notifier);
                                if (value == 'success') {
                                  Navigator.of(context).pushNamed(
                                    '/marketplace-success',
                                    arguments: MarketplaceSuccessPayload(
                                      name: 'Brother Samuel',
                                      skillName: listing.title,
                                      location: listing.location,
                                      listingId: listing.id,
                                    ),
                                  );
                                } else if (value == 'block') {
                                  await controller.blockUser(
                                    blockedId: listing.id,
                                    reasonCode: 'HARASSMENT',
                                  );
                                } else if (value == 'mute') {
                                  await controller.muteUser(mutedId: listing.id);
                                } else if (value == 'report') {
                                  await controller.reportUser(
                                    reportedId: listing.id,
                                    reasonCode: 'SCAM',
                                    detail: 'Reported from marketplace row menu',
                                  );
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'success',
                                  child: Text('Open Success Preview'),
                                ),
                                PopupMenuItem(
                                  value: 'block',
                                  child: Text('Block User'),
                                ),
                                PopupMenuItem(
                                  value: 'mute',
                                  child: Text('Mute User'),
                                ),
                                PopupMenuItem(
                                  value: 'report',
                                  child: Text('Report User'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mission Peer Chat Preview',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnSurface,
                ),
              ),
              const SizedBox(height: 8),
              ...previewMessages.map(
                (message) => Align(
                  alignment:
                      message.isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: message.isMine
                          ? AppColors.primaryNavy.withValues(alpha: 0.14)
                          : AppColors.primaryNavy.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.senderName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                message.body,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textOnSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!message.isMine)
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_horiz,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                            onSelected: (value) async {
                              final controller = ref.read(boundaryControllerProvider.notifier);
                              if (value == 'block') {
                                await controller.blockUser(
                                  blockedId: message.senderUserId,
                                  reasonCode: 'HARASSMENT',
                                );
                              } else if (value == 'mute') {
                                await controller.muteUser(mutedId: message.senderUserId);
                              } else if (value == 'report') {
                                await controller.reportUser(
                                  reportedId: message.senderUserId,
                                  reasonCode: 'HARASSMENT',
                                  detail: 'Reported from mission peer chat bubble',
                                );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'block',
                                child: Text('Block User'),
                              ),
                              PopupMenuItem(
                                value: 'mute',
                                child: Text('Mute User'),
                              ),
                              PopupMenuItem(
                                value: 'report',
                                child: Text('Report User'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                'Blocked users are collapsed/hidden in shared group chats to reduce friction.',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chatGuardianComposer(
    BuildContext context,
    WidgetRef ref,
    TextEditingController messageController,
    SilentGuardianState guardian,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Silent Guardian (On-Device AI)',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: messageController,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              hintText: 'Type a message for local scan...'
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: guardian.isLoading
                    ? null
                    : () async {
                        final text = messageController.text.trim();
                        if (text.isEmpty) return;
                        final sent = await ref.read(silentGuardianControllerProvider.notifier).guardAndSend(
                              roomId: 'global-ysa-room',
                              body: text,
                              userConfirmedAfterNudge: true,
                            );
                        if (sent) {
                          messageController.clear();
                        }
                      },
                child: const Text('Send with Guardian'),
              ),
              FilledButton.tonal(
                onPressed: guardian.isLoading
                    ? null
                    : () async {
                        final text = messageController.text.trim();
                        if (text.isEmpty) return;
                        await ref.read(silentGuardianControllerProvider.notifier).reportWithFranking(
                              roomId: 'global-ysa-room',
                              reportedUserId: 'u1003',
                              conductCategory: 'DISRESPECTFUL_LANGUAGE',
                              evidenceMessage: text,
                            );
                      },
                child: const Text('Report w/ Franking'),
              ),
            ],
          ),
          if (guardian.lastNudge != null) ...[
            const SizedBox(height: 6),
            Text(
              guardian.lastNudge!,
              style: TextStyle(
                fontSize: 10,
                color: (guardian.lastRiskScore ?? 0) >= 70
                    ? AppColors.warmCrimson
                    : AppColors.stewardshipGreen,
              ),
            ),
          ],
          if (guardian.error != null) ...[
            const SizedBox(height: 4),
            Text(
              guardian.error!,
              style: const TextStyle(fontSize: 10, color: AppColors.warmCrimson),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref, {
    required String label,
    required String? value,
    required bool selected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        ref.read(selectedMarketplaceCategoryProvider.notifier).state = value;
      },
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? AppColors.primaryNavy : AppColors.textMuted,
      ),
      selectedColor: AppColors.pathwayAmber.withValues(alpha: 0.3),
      backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected
              ? AppColors.pathwayAmber.withValues(alpha: 0.9)
              : AppColors.primaryNavy.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

