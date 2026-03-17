import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AppFlowLogicMapScreen extends StatelessWidget {
  const AppFlowLogicMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPG App Flow Logic Map')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _LoopCard(
            title: '1) Authentication Loop',
            steps: [
              'Splash → Onboarding → Sign-Up/Login',
              'Phone OTP verification',
              'Profile completion (Mission / Pathway / Genotype)',
              'Destination: Main Bento Dashboard',
            ],
          ),
          SizedBox(height: 12),
          _LoopCard(
            title: '2) Social Loop',
            steps: [
              'Dashboard → Scroll Feed → Watch Video',
              'Like/Comment → AI Moderation Scan → Post Visible',
              'Mission Peer Search → Send Message → Encrypted Chat',
            ],
          ),
          SizedBox(height: 12),
          _LoopCard(
            title: '3) Economic Loop (Marketplace)',
            steps: [
              'Dashboard Search → Filter by LGA/Gender → View Talent Profile',
              'Profile → Pay Fee → Upload Certificate → Admin Approval → Live Listing',
            ],
          ),
          SizedBox(height: 12),
          _LoopCard(
            title: '4) Safety Loop (Invisible Flow)',
            steps: [
              'Message/Post → Flag for Church Conduct → Encrypted Franking',
              'Control Room Alert → Admin Resolution → User Notification/Suspension',
            ],
          ),
          SizedBox(height: 12),
          _LoopCard(
            title: 'Deep Linking (2026 Pro-Tip)',
            steps: [
              'Shared talent link opens directly to specific talent page.',
              'Shared mission group link opens directly to that group context.',
              'Avoid landing users on generic home for shared-intent journeys.',
            ],
          ),
        ],
      ),
    );
  }
}

class _LoopCard extends StatelessWidget {
  const _LoopCard({
    required this.title,
    required this.steps,
  });

  final String title;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryNavy,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $step', style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
