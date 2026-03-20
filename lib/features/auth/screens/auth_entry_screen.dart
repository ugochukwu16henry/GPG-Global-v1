import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../backend/providers/backend_live_providers.dart';
import '../providers/session_provider.dart';
import '../../home/widgets/g_nexus_logo.dart';
import '../../home/widgets/glass_card.dart';

enum AuthEntryMode {
  userSignIn,
  userSignUp,
  moderatorSignIn,
  moderatorSignUp,
  adminSignIn
}

class AuthEntryScreen extends ConsumerStatefulWidget {
  const AuthEntryScreen({
    super.key,
    required this.mode,
  });

  final AuthEntryMode mode;

  @override
  ConsumerState<AuthEntryScreen> createState() => _AuthEntryScreenState();
}

class _AuthEntryScreenState extends ConsumerState<AuthEntryScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _codeController = TextEditingController();
  final _secretController = TextEditingController();
  CommunityIdentity _identity = CommunityIdentity.friendSeeker;

  Timer? _quoteTimer;
  int _quoteIndex = 0;
  String _journeyChoice = 'Mission';
  int _signUpStep = 0;

  static const _impactQuotes = <String>[
    'Community Impact: Safe Connection → Real Growth.',
    'Community Impact: Faith-Filled Companionship that Strengthens.',
    'Community Impact: Education to Employment, guided by standards.',
    'Community Impact: Trusted Talent, empowered locally.',
  ];

  @override
  void initState() {
    super.initState();
    _quoteTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _quoteIndex = (_quoteIndex + 1) % _impactQuotes.length;
      });
    });
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _codeController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  String _title() {
    return switch (widget.mode) {
      AuthEntryMode.userSignIn => 'User Sign In',
      AuthEntryMode.userSignUp => 'User Sign Up',
      AuthEntryMode.moderatorSignIn => 'Moderator Sign In',
      AuthEntryMode.moderatorSignUp => 'Moderator Sign Up',
      AuthEntryMode.adminSignIn => 'Admin Sign In',
    };
  }

  Future<void> _submit() async {
    final sessionController = ref.read(sessionControllerProvider.notifier);

    switch (widget.mode) {
      case AuthEntryMode.userSignIn:
        await ref.read(backendAuthControllerProvider.notifier).verifyOtp(
              phone: _phoneController.text.trim(),
              otpCode: _otpController.text.trim(),
              displayName: _nameController.text.trim().isEmpty
                  ? 'User'
                  : _nameController.text.trim(),
              isMember: null,
            );
        if (mounted &&
            ref.read(sessionControllerProvider).role == AppRole.user) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/user-app', (_) => false);
        }
        break;
      case AuthEntryMode.userSignUp:
        await ref.read(backendAuthControllerProvider.notifier).verifyOtp(
              phone: _phoneController.text.trim(),
              otpCode: _otpController.text.trim(),
              displayName: _nameController.text.trim().isEmpty
                  ? 'New User'
                  : _nameController.text.trim(),
              isMember: _identity == CommunityIdentity.member,
            );
        if (mounted &&
            ref.read(sessionControllerProvider).role == AppRole.user) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/user-app', (_) => false);
        }
        break;
      case AuthEntryMode.moderatorSignIn:
      case AuthEntryMode.moderatorSignUp:
        try {
          final gateway = ref.read(backendGatewayProvider);
          final result = await gateway
              .redeemModeratorInviteCode(_codeController.text.trim());
          sessionController.setModeratorSession(
            sessionToken: result['sessionToken']!,
            gatheringPlace: result['gatheringPlace']!,
            moderatorRole: result['roleLabel']!,
          );
          ref.read(backendUserIdProvider.notifier).state = result['userId']!;
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/moderator-dashboard', (_) => false);
        } catch (error) {
          sessionController.setStatusMessage(error.toString());
        }
        break;
      case AuthEntryMode.adminSignIn:
        try {
          final gateway = ref.read(backendGatewayProvider);
          final result =
              await gateway.issueAdminSession(_secretController.text.trim());
          sessionController.setAdminSession(
            userId: result['userId']!,
            sessionToken: result['sessionToken']!,
          );
          ref.read(backendUserIdProvider.notifier).state = result['userId']!;
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/admin-dashboard', (_) => false);
        } catch (error) {
          sessionController.setStatusMessage(error.toString());
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(sessionControllerProvider).statusMessage;
    final authState = ref.watch(backendAuthControllerProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isSplitGlass = width >= 900 &&
        (widget.mode == AuthEntryMode.userSignIn ||
            widget.mode == AuthEntryMode.userSignUp);

    if (isSplitGlass) {
      final isSignUp = widget.mode == AuthEntryMode.userSignUp;
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              // Left: blurred brand background + rotating quote.
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryNavy.withValues(alpha: 0.85),
                        AppColors.pathwayAmber.withValues(alpha: 0.18),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Big blurred logo.
                      Positioned(
                        left: -40,
                        top: -40,
                        child: Opacity(
                          opacity: 0.22,
                          child: const GNexusLogo(
                            size: 220,
                            variant: LogoSurfaceVariant.birthdayGlow,
                          ),
                        ),
                      ),
                      // Quote content.
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'GPG Global',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: AppColors.surfaceWhite,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _impactQuotes[_quoteIndex],
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                                color: AppColors.surfaceWhite
                                    .withValues(alpha: 0.92),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Digital Sanctuary for BYU-Pathway students and Return Missionaries',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.surfaceWhite
                                    .withValues(alpha: 0.82),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right: glass card form with floating labels.
              Expanded(
                flex: 4,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(18),
                        blur: 12,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.shield_rounded, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _title(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (!isSignUp)
                                    IconButton(
                                      tooltip: 'About this step',
                                      onPressed: () {
                                        // No-op, just a UX affordance.
                                      },
                                      icon: const Icon(
                                          Icons.info_outline_rounded),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              if (!isSignUp) ...[
                                // One-tap login options.
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _oneTapLoginButton(
                                      icon: Icons.login_rounded,
                                      label: 'Google',
                                      onTap: () => _showNotConfigured(context),
                                    ),
                                    _oneTapLoginButton(
                                      icon: Icons.apple_rounded,
                                      label: 'Apple',
                                      onTap: () => _showNotConfigured(context),
                                    ),
                                    _oneTapLoginButton(
                                      icon: Icons.auto_stories_rounded,
                                      label: 'Church',
                                      onTap: () => _showNotConfigured(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                              ],

                              if (isSignUp) ...[
                                _desktopSignUpStepper(),
                                const SizedBox(height: 12),
                              ],

                              if (isSignUp) ...[
                                _desktopSignUpBody(),
                              ] else ...[
                                // Floating-label sign-in (phone + OTP).
                                TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone number',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'OTP code',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                ),
                                if (authState.devOtpPreview != null) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    'Dev OTP preview: ${authState.devOtpPreview}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                                const SizedBox(height: 14),
                                FilledButton.tonal(
                                  onPressed: authState.isLoading
                                      ? null
                                      : () => ref
                                          .read(backendAuthControllerProvider
                                              .notifier)
                                          .sendOtp(
                                              _phoneController.text.trim()),
                                  child: const Text('Send OTP'),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Submit/message UI.
                              if (!isSignUp || _signUpStep == 2) ...[
                                FilledButton(
                                  onPressed:
                                      authState.isLoading ? null : _submit,
                                  child: const Text('Continue'),
                                ),
                                if (authState.message != null) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    authState.message!,
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ],
                                if (authState.error != null) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    authState.error!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                                if (status != null) ...[
                                  const SizedBox(height: 10),
                                  Text(status,
                                      style:
                                          const TextStyle(color: Colors.red)),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_title())),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.mode == AuthEntryMode.userSignIn ||
                  widget.mode == AuthEntryMode.userSignUp)
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Display Name'),
                ),
              if (widget.mode == AuthEntryMode.userSignIn ||
                  widget.mode == AuthEntryMode.userSignUp) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 380;
                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'OTP Code'),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonal(
                            onPressed: authState.isLoading
                                ? null
                                : () => ref
                                    .read(
                                        backendAuthControllerProvider.notifier)
                                    .sendOtp(_phoneController.text.trim()),
                            child: const Text('Send OTP'),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'OTP Code'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: authState.isLoading
                              ? null
                              : () => ref
                                  .read(backendAuthControllerProvider.notifier)
                                  .sendOtp(_phoneController.text.trim()),
                          child: const Text('Send OTP'),
                        ),
                      ],
                    );
                  },
                ),
                if (authState.devOtpPreview != null) ...[
                  const SizedBox(height: 8),
                  Text('Dev OTP preview: ${authState.devOtpPreview}'),
                ],
              ],
              if (widget.mode == AuthEntryMode.userSignUp) ...[
                const SizedBox(height: 14),
                const Text('How would you like to join us today?',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                RadioListTile<CommunityIdentity>(
                  value: CommunityIdentity.member,
                  groupValue: _identity,
                  onChanged: (value) => setState(() => _identity = value!),
                  title: const Text(
                      'Member (The Church of Jesus Christ of Latter-day Saints)'),
                ),
                RadioListTile<CommunityIdentity>(
                  value: CommunityIdentity.friendSeeker,
                  groupValue: _identity,
                  onChanged: (value) => setState(() => _identity = value!),
                  title: const Text(
                      'Friend / Seeker (faith, skill-building, community)'),
                ),
              ],
              if (widget.mode == AuthEntryMode.moderatorSignIn ||
                  widget.mode == AuthEntryMode.moderatorSignUp)
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Moderator Access Code',
                    hintText: 'Code generated by Admin per Gathering Place',
                  ),
                ),
              if (widget.mode == AuthEntryMode.adminSignIn)
                TextField(
                  controller: _secretController,
                  decoration:
                      const InputDecoration(labelText: 'Admin Secret Key'),
                  obscureText: true,
                ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: authState.isLoading ? null : _submit,
                child: const Text('Continue'),
              ),
              if (authState.message != null) ...[
                const SizedBox(height: 10),
                Text(authState.message!,
                    style: const TextStyle(color: Colors.green)),
              ],
              if (authState.error != null) ...[
                const SizedBox(height: 10),
                Text(authState.error!,
                    style: const TextStyle(color: Colors.red)),
              ],
              if (status != null) ...[
                const SizedBox(height: 10),
                Text(status, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _oneTapLoginButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return FilledButton.tonal(
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  void _showNotConfigured(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('One-tap login not configured yet.')),
    );
  }

  Widget _desktopSignUpStepper() {
    final steps = const ['Identity', 'Journey', 'Security'];
    return Row(
      children: List.generate(steps.length, (index) {
        final active = index == _signUpStep;
        final done = index < _signUpStep;
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: (active || done)
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryNavy,
                                AppColors.pathwayAmber
                              ],
                            )
                          : null,
                      color: (active || done)
                          ? null
                          : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: (active || done)
                            ? AppColors.textOnNavy
                            : AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                      fontSize: 12,
                      color:
                          active ? AppColors.primaryNavy : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (index != steps.length - 1) ...[
                const SizedBox(height: 6),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _desktopSignUpBody() {
    final authState = ref.watch(backendAuthControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_signUpStep == 0) ...[
          const Text(
            'Step 1 · Identity',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          RadioListTile<CommunityIdentity>(
            value: CommunityIdentity.member,
            groupValue: _identity,
            onChanged: (value) => setState(() => _identity = value!),
            title: const Text('Member'),
            subtitle:
                const Text('The Church of Jesus Christ of Latter-day Saints'),
          ),
          RadioListTile<CommunityIdentity>(
            value: CommunityIdentity.friendSeeker,
            groupValue: _identity,
            onChanged: (value) => setState(() => _identity = value!),
            title: const Text('Friend / Seeker'),
            subtitle: const Text('Faith, skill-building, and community'),
          ),
          const SizedBox(height: 14),
          FilledButton.tonal(
            onPressed: () => setState(() => _signUpStep = 1),
            child: const Text('Next · Journey'),
          ),
        ] else if (_signUpStep == 1) ...[
          const Text(
            'Step 2 · Journey',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ChoiceChip(
                label: const Text('Mission'),
                selected: _journeyChoice == 'Mission',
                onSelected: (_) => setState(() => _journeyChoice = 'Mission'),
              ),
              ChoiceChip(
                label: const Text('Pathway'),
                selected: _journeyChoice == 'Pathway',
                onSelected: (_) => setState(() => _journeyChoice = 'Pathway'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.tonal(
            onPressed: () => setState(() => _signUpStep = 2),
            child: const Text('Next · Security'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _signUpStep = 0),
            child: const Text('Back'),
          ),
        ] else ...[
          const Text(
            'Step 3 · Security (OTP)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display name',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'OTP code',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            obscureText: true,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Password handled by OTP sign-in',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.tonal(
            onPressed: authState.isLoading
                ? null
                : () => ref
                    .read(backendAuthControllerProvider.notifier)
                    .sendOtp(_phoneController.text.trim()),
            child: const Text('Send OTP'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _signUpStep = 1),
            child: const Text('Back to Journey'),
          ),
        ],
      ],
    );
  }
}
