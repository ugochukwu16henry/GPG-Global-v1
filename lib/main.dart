import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/screens/admin_command_center_screen.dart';
import 'features/auth/providers/session_provider.dart';
import 'features/auth/screens/auth_entry_screen.dart';
import 'features/auth/screens/marketing_landing_screen.dart';
import 'features/auth/screens/simple_info_screen.dart';
import 'features/home/screens/app_flow_logic_map_screen.dart';
import 'features/home/screens/deep_link_target_screen.dart';
import 'features/home/screens/marketplace_success_screen.dart';
import 'features/home/screens/user_app_shell_screen.dart';
import 'features/home/screens/vendor_studio_screen.dart';
import 'features/moderator/screens/moderator_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: GpgGlobalApp(),
    ),
  );
}

class GpgGlobalApp extends ConsumerWidget {
  const GpgGlobalApp({super.key});

  Route<dynamic> _onGenerateRoute(RouteSettings settings, WidgetRef ref) {
    final name = settings.name ?? '/';
    final uri = Uri.parse(name);
    final session = ref.read(sessionControllerProvider);

    Route<dynamic> denyAccess() {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const SimpleInfoScreen(
          title: 'Access Restricted',
          body:
              'This area is restricted to another role. Please sign in with the correct account type.',
        ),
      );
    }

    if (uri.path == '/') {
      return MaterialPageRoute(
          builder: (_) => const MarketingLandingScreen(), settings: settings);
    }

    if (uri.path == '/signin-user') {
      return MaterialPageRoute(
        builder: (_) => const AuthEntryScreen(mode: AuthEntryMode.userSignIn),
        settings: settings,
      );
    }

    if (uri.path == '/signup-user') {
      return MaterialPageRoute(
        builder: (_) => const AuthEntryScreen(mode: AuthEntryMode.userSignUp),
        settings: settings,
      );
    }

    if (uri.path == '/signin-moderator') {
      return MaterialPageRoute(
        builder: (_) =>
            const AuthEntryScreen(mode: AuthEntryMode.moderatorSignIn),
        settings: settings,
      );
    }

    if (uri.path == '/signup-moderator') {
      return MaterialPageRoute(
        builder: (_) =>
            const AuthEntryScreen(mode: AuthEntryMode.moderatorSignUp),
        settings: settings,
      );
    }

    if (uri.path == '/signin-admin') {
      return MaterialPageRoute(
        builder: (_) => const AuthEntryScreen(mode: AuthEntryMode.adminSignIn),
        settings: settings,
      );
    }

    if (uri.path == '/about') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const SimpleInfoScreen(
          title: 'About GPG',
          body:
              'GPG Gathering Place Global is a faith-centered social and marketplace ecosystem designed for safe community growth, discipleship, and skill-building.',
        ),
      );
    }

    if (uri.path == '/terms') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const SimpleInfoScreen(
          title: 'Terms',
          body:
              'Use of the platform requires wholesome conduct and respect for community standards.',
        ),
      );
    }

    if (uri.path == '/privacy') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const SimpleInfoScreen(
          title: 'Privacy',
          body:
              'Religious and safety-sensitive data are treated as protected information. Users may keep affiliation private from public profile views.',
        ),
      );
    }

    if (uri.path == '/legal') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const SimpleInfoScreen(
          title: 'Legal',
          body:
              'GPG follows applicable data-protection obligations and moderation accountability standards for community safety.',
        ),
      );
    }

    if (uri.path == '/user-app') {
      if (session.role != AppRole.user) {
        return denyAccess();
      }
      return MaterialPageRoute(
          builder: (_) => const UserAppShellScreen(), settings: settings);
    }

    if (uri.path == '/vendor-studio') {
      if (session.role != AppRole.user) {
        return denyAccess();
      }
      return MaterialPageRoute(
          builder: (_) => const VendorStudioScreen(), settings: settings);
    }

    if (uri.path == '/moderator-dashboard') {
      if (session.role != AppRole.moderator) {
        return denyAccess();
      }
      return MaterialPageRoute(
          builder: (_) => const ModeratorDashboardScreen(), settings: settings);
    }

    if (uri.path == '/admin-dashboard') {
      if (session.role != AppRole.admin) {
        return denyAccess();
      }
      return MaterialPageRoute(
          builder: (_) => const AdminCommandCenterScreen(), settings: settings);
    }

    if (uri.path == '/app-flow-map') {
      return MaterialPageRoute(
          builder: (_) => const AppFlowLogicMapScreen(), settings: settings);
    }

    if (uri.path == '/marketplace-success') {
      final args = settings.arguments as MarketplaceSuccessPayload?;
      final payload = args ??
          const MarketplaceSuccessPayload(
            name: 'Brother Samuel',
            skillName: 'Certified Electrician',
            location: 'Ikeja, Lagos',
            listingId: 'm1',
          );
      return MaterialPageRoute(
        builder: (_) => MarketplaceSuccessScreen(payload: payload),
        settings: settings,
      );
    }

    final segments = uri.pathSegments;
    if (segments.length == 2 && segments.first == 'talent') {
      return MaterialPageRoute(
        builder: (_) => DeepLinkTargetScreen(
          title: 'Talent Listing',
          id: segments[1],
          description:
              'Opened via deep link directly to a specific talent listing.',
        ),
        settings: settings,
      );
    }

    if (segments.length == 2 && segments.first == 'mission-group') {
      return MaterialPageRoute(
        builder: (_) => DeepLinkTargetScreen(
          title: 'Mission Group',
          id: segments[1],
          description:
              'Opened via deep link directly to a mission group context.',
        ),
        settings: settings,
      );
    }

    return MaterialPageRoute(
        builder: (_) => const MarketingLandingScreen(), settings: settings);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'GPG Gathering Place Global',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      onGenerateRoute: (settings) => _onGenerateRoute(settings, ref),
      initialRoute: '/',
    );
  }
}
