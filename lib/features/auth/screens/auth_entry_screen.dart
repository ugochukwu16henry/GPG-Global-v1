import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backend/providers/backend_live_providers.dart';
import '../providers/session_provider.dart';

enum AuthEntryMode { userSignIn, userSignUp, moderatorSignIn, moderatorSignUp, adminSignIn }

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

  @override
  void dispose() {
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
              displayName: _nameController.text.trim().isEmpty ? 'User' : _nameController.text.trim(),
              isMember: null,
            );
        if (mounted && ref.read(sessionControllerProvider).role == AppRole.user) {
          Navigator.of(context).pushNamedAndRemoveUntil('/user-app', (_) => false);
        }
        break;
      case AuthEntryMode.userSignUp:
        await ref.read(backendAuthControllerProvider.notifier).verifyOtp(
              phone: _phoneController.text.trim(),
              otpCode: _otpController.text.trim(),
              displayName: _nameController.text.trim().isEmpty ? 'New User' : _nameController.text.trim(),
              isMember: _identity == CommunityIdentity.member,
            );
        if (mounted && ref.read(sessionControllerProvider).role == AppRole.user) {
          Navigator.of(context).pushNamedAndRemoveUntil('/user-app', (_) => false);
        }
        break;
      case AuthEntryMode.moderatorSignIn:
      case AuthEntryMode.moderatorSignUp:
        try {
          final gateway = ref.read(backendGatewayProvider);
          final result = await gateway.redeemModeratorInviteCode(_codeController.text.trim());
          sessionController.setModeratorSession(
            sessionToken: result['sessionToken']!,
            gatheringPlace: result['gatheringPlace']!,
            moderatorRole: result['roleLabel']!,
          );
          ref.read(backendUserIdProvider.notifier).state = result['userId']!;
          Navigator.of(context).pushNamedAndRemoveUntil('/moderator-dashboard', (_) => false);
        } catch (error) {
          sessionController.setStatusMessage(error.toString());
        }
        break;
      case AuthEntryMode.adminSignIn:
        try {
          final gateway = ref.read(backendGatewayProvider);
          final result = await gateway.issueAdminSession(_secretController.text.trim());
          sessionController.setAdminSession(
            userId: result['userId']!,
            sessionToken: result['sessionToken']!,
          );
          ref.read(backendUserIdProvider.notifier).state = result['userId']!;
          Navigator.of(context).pushNamedAndRemoveUntil('/admin-dashboard', (_) => false);
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

    return Scaffold(
      appBar: AppBar(title: Text(_title())),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.mode == AuthEntryMode.userSignIn || widget.mode == AuthEntryMode.userSignUp)
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Display Name'),
                ),
              if (widget.mode == AuthEntryMode.userSignIn || widget.mode == AuthEntryMode.userSignUp) ...[
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
                            decoration: const InputDecoration(labelText: 'OTP Code'),
                          ),
                          const SizedBox(height: 8),
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
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'OTP Code'),
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
                const Text('How would you like to join us today?', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                RadioListTile<CommunityIdentity>(
                  value: CommunityIdentity.member,
                  groupValue: _identity,
                  onChanged: (value) => setState(() => _identity = value!),
                  title: const Text('Member (The Church of Jesus Christ of Latter-day Saints)'),
                ),
                RadioListTile<CommunityIdentity>(
                  value: CommunityIdentity.friendSeeker,
                  groupValue: _identity,
                  onChanged: (value) => setState(() => _identity = value!),
                  title: const Text('Friend / Seeker (faith, skill-building, community)'),
                ),
              ],
              if (widget.mode == AuthEntryMode.moderatorSignIn || widget.mode == AuthEntryMode.moderatorSignUp)
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
                  decoration: const InputDecoration(labelText: 'Admin Secret Key'),
                  obscureText: true,
                ),
              const SizedBox(height: 18),
              FilledButton(
                  onPressed: authState.isLoading ? null : _submit,
                child: const Text('Continue'),
              ),
                if (authState.message != null) ...[
                  const SizedBox(height: 10),
                  Text(authState.message!, style: const TextStyle(color: Colors.green)),
                ],
                if (authState.error != null) ...[
                  const SizedBox(height: 10),
                  Text(authState.error!, style: const TextStyle(color: Colors.red)),
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
}
