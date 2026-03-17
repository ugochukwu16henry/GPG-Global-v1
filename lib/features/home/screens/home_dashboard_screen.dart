import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/custom_nav_bar.dart';
import '../widgets/g_nexus_logo.dart';
import '../widgets/gathering_feed.dart';
import '../widgets/pathway_progress_tracker.dart';
import '../widgets/profile_card.dart';

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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const GNexusLogo(size: 40),
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
                  'Digital Sanctuary',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          Expanded(child: GatheringFeed()),
        ],
      ),
    );
  }
}
