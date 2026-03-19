import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../backend/providers/backend_live_providers.dart';
import '../widgets/g_nexus_logo.dart';
import '../widgets/glass_card.dart';

class MarketplaceTalentDetailScreen extends ConsumerStatefulWidget {
  const MarketplaceTalentDetailScreen({
    super.key,
    required this.vendor,
    this.entryContext = 'Marketplace',
  });

  final Map<String, dynamic> vendor;
  final String entryContext;

  @override
  ConsumerState<MarketplaceTalentDetailScreen> createState() =>
      _MarketplaceTalentDetailScreenState();
}

class _MarketplaceTalentDetailScreenState
    extends ConsumerState<MarketplaceTalentDetailScreen> {
  late final TextEditingController _messageController;
  bool _isSending = false;
  String? _status;
  String? _error;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(
      text:
          'Hi, I found your profile on GPG and I would like to hire you. Could we discuss details?',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendHireRequest() async {
    final targetUserId = (widget.vendor['userId'] ?? '').toString();
    if (targetUserId.isEmpty) {
      setState(() {
        _error = 'Vendor user ID is unavailable for hire request.';
      });
      return;
    }

    final body = _messageController.text.trim();
    if (body.isEmpty) {
      setState(() {
        _error = 'Please write a hire request message.';
      });
      return;
    }

    setState(() {
      _isSending = true;
      _error = null;
      _status = null;
    });

    try {
      final gateway = ref.read(backendGatewayProvider);
      final senderUserId = ref.read(backendUserIdProvider);
      final roomId = 'hire-request-$targetUserId';

      final moderationResult = await gateway.sendChatForModeration(
        senderUserId: senderUserId,
        roomId: roomId,
        body: body,
      );

      if (!mounted) return;
      HapticFeedback.lightImpact();
      setState(() {
        _isSending = false;
        _status = moderationResult == null
            ? 'Hire request sent successfully.'
            : 'Hire request sent with moderation note: $moderationResult';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendorName =
        (widget.vendor['vendorName'] ?? widget.vendor['title'] ?? 'Vendor')
            .toString();
    final category = (widget.vendor['category'] ?? 'General').toString();
    final country = (widget.vendor['country'] ?? '').toString();
    final state = (widget.vendor['state'] ?? '').toString();
    final pricing =
        (widget.vendor['servicePricing'] as List<dynamic>? ?? const <dynamic>[])
            .cast<Map<String, dynamic>>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Talent Detail'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Talent Profile',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
              color: AppColors.pathwayAmber,
            ),
          ),
          const SizedBox(height: 6),
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GNexusLogo(size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendorName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$category · $state${state.isNotEmpty && country.isNotEmpty ? ', ' : ''}$country',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Opened from ${widget.entryContext}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Service Pricing',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                if (pricing.isEmpty)
                  const Text(
                    'No service pricing has been published yet.',
                    style: TextStyle(color: AppColors.textMuted),
                  )
                else
                  ...pricing.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              (entry['serviceName'] ?? 'Service').toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            '${entry['pricingMode'] ?? 'FIXED'} · ${entry['amountUsd'] ?? ''} ${entry['currency'] ?? 'USD'}',
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hire Request',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _messageController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Message',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _isSending ? null : _sendHireRequest,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(220, 48),
                  ),
                  child: Text(_isSending ? 'Sending...' : 'Send Hire Request'),
                ),
                if (_status != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _status!,
                    style: const TextStyle(color: AppColors.stewardshipGreen),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.warmCrimson),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
