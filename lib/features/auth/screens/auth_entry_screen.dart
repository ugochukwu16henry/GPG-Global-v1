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
  final _codeController = TextEditingController();
  final _secretController = TextEditingController();
  CommunityIdentity _identity = CommunityIdentity.friendSeeker;

  @override
  void dispose() {
    _nameController.dispose();
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
        sessionController.signInUser(displayName: _nameController.text.trim().isEmpty ? 'User' : _nameController.text.trim());
        if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/user-app', (_) => false);
        break;
      case AuthEntryMode.userSignUp:
        sessionController.signUpUser(
          displayName: _nameController.text.trim().isEmpty ? 'New User' : _nameController.text.trim(),
          identity: _identity,
        );
        if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/user-app', (_) => false);
        break;
      case AuthEntryMode.moderatorSignIn:
      case AuthEntryMode.moderatorSignUp:
        final ok = sessionController.signInModeratorWithCode(_codeController.text.trim());
        if (ok && mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/moderator-dashboard', (_) => false);
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
        } catch (_) {
          sessionController.signInAdmin(_secretController.text.trim());
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(sessionControllerProvider).statusMessage;

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
                onPressed: _submit,
                child: const Text('Continue'),
              ),
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
