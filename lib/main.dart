import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/app_flow_logic_map_screen.dart';
import 'features/home/screens/deep_link_target_screen.dart';
import 'features/home/screens/home_dashboard_screen.dart';
import 'features/home/screens/marketplace_success_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(
    const ProviderScope(
      child: GpgGlobalApp(),
    ),
  );
}

class GpgGlobalApp extends StatelessWidget {
  const GpgGlobalApp({super.key});

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    final uri = Uri.parse(name);

    if (uri.path == '/') {
      return MaterialPageRoute(builder: (_) => const HomeDashboardScreen(), settings: settings);
    }

    if (uri.path == '/app-flow-map') {
      return MaterialPageRoute(builder: (_) => const AppFlowLogicMapScreen(), settings: settings);
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
          description: 'Opened via deep link directly to a specific talent listing.',
        ),
        settings: settings,
      );
    }

    if (segments.length == 2 && segments.first == 'mission-group') {
      return MaterialPageRoute(
        builder: (_) => DeepLinkTargetScreen(
          title: 'Mission Group',
          id: segments[1],
          description: 'Opened via deep link directly to a mission group context.',
        ),
        settings: settings,
      );
    }

    return MaterialPageRoute(builder: (_) => const HomeDashboardScreen(), settings: settings);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPG Gathering Place Global',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      onGenerateRoute: _onGenerateRoute,
      initialRoute: '/',
    );
  }
}
