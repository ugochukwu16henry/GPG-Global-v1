import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../backend/providers/backend_live_providers.dart';
import '../../admin/screens/admin_command_center_screen.dart';
import '../widgets/custom_nav_bar.dart';
import '../widgets/g_nexus_logo.dart';
import '../widgets/gathering_feed.dart';
import '../widgets/pathway_progress_tracker.dart';
import '../widgets/profile_card.dart';
import '../widgets/live_events_and_marketplace_demo.dart';
import '../widgets/talents_near_you_panel.dart';

/// Home Dashboard with Bento Grid: Profile (top-left), Pathway Progress (top-right),
/// scrollable Gathering Feed (center). Custom nav bar and G-Nexus header.
class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 600;
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildAuthBanner(context),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (isWide) {
                    return _buildBentoWeb(constraints);
                  }
                  return _buildBentoMobile(constraints);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
    );
  }

  Widget _buildAuthBanner(BuildContext context) {
    final activeUserId = ref.watch(backendUserIdProvider);
    final authState = ref.watch(backendAuthControllerProvider);
    final verified = authState.message?.startsWith('Phone verified') ?? false;
    final hasError = authState.error != null;

    final bannerColor = hasError
        ? AppColors.warmCrimson.withValues(alpha: 0.1)
        : verified
            ? AppColors.stewardshipGreen.withValues(alpha: 0.12)
            : AppColors.pathwayAmber.withValues(alpha: 0.15);

    final textColor = hasError
        ? AppColors.warmCrimson
        : verified
            ? AppColors.stewardshipGreen
            : AppColors.primaryNavy;

    final statusText = hasError
        ? 'Auth issue: ${authState.error}'
        : verified
            ? 'Verified'
            : 'Unverified (send OTP in Profile card)';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            verified ? Icons.verified_user_rounded : Icons.privacy_tip_outlined,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Active User: $activeUserId · $statusText',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const GNexusLogo(size: 40, variant: LogoSurfaceVariant.appIcon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GPG Gathering Place Global',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryNavy,
                  ),
                ),
                Text(
                  'Welcome Home · Glad you\'re here',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AdminCommandCenterScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GNexusLogo(
                    size: 20,
                    variant: LogoSurfaceVariant.controlRoomMonochrome,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Control Room',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoMobile(BoxConstraints constraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: ProfileCard(),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: PathwayProgressTracker(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const LiveEventsAndMarketplaceDemo(),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight - 220,
            ),
            child: GatheringFeed(),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoWeb(BoxConstraints constraints) {
    final feedHeight = (constraints.maxHeight * 0.5).clamp(220.0, 520.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 280, child: ProfileCard()),
                const SizedBox(width: 24),
                SizedBox(width: 200, child: PathwayProgressTracker()),
              ],
            ),
            const SizedBox(height: 24),
            const LiveEventsAndMarketplaceDemo(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: SizedBox(height: feedHeight, child: GatheringFeed()),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  flex: 3,
                  child: TalentsNearYouPanel(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
