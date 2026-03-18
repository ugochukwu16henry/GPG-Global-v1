import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MarketingLandingScreen extends StatelessWidget {
  const MarketingLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 820;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'GP_Global_logo.png',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'GPG Gathering Place Global',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/about'),
                        child: const Text('About'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment:
                        compact ? WrapAlignment.start : WrapAlignment.end,
                    children: [
                      FilledButton.tonal(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/signin-user'),
                        child: const Text('Sign In User'),
                      ),
                      FilledButton.tonal(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/signup-user'),
                        child: const Text('Sign Up User'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => Navigator.of(context)
                            .pushNamed('/signin-moderator'),
                        child: const Text('Sign In Moderator'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => Navigator.of(context)
                            .pushNamed('/signup-moderator'),
                        child: const Text('Sign Up Moderator'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'GP_Global_logo.png',
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'A Safe, Spiritual, and Social Community',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: compact ? 24 : 30,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'GPG connects Members, Friends, and Seekers through wholesome reels, encrypted chat, and a trusted talent marketplace with local gathering-place leadership.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                              height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: const [
                            Chip(label: Text('Faith-Centered Community')),
                            Chip(label: Text('Secure Messaging')),
                            Chip(label: Text('Verified Talent Marketplace')),
                            Chip(label: Text('AI Wholesome Guardrails')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Wrap(
                spacing: 14,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/signin-admin'),
                    child: const Text('Admin'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/terms'),
                    child: const Text('Terms'),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/privacy'),
                    child: const Text('Privacy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/legal'),
                    child: const Text('Legal'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
