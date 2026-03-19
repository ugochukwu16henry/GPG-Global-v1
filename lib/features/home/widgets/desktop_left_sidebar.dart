import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'glass_card.dart';
import 'g_nexus_logo.dart';

enum CommandCenterTab { home, peers, marketplace, academy, settings }

class DesktopLeftSidebar extends StatefulWidget {
  const DesktopLeftSidebar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final CommandCenterTab selectedTab;
  final ValueChanged<CommandCenterTab> onTabSelected;

  @override
  State<DesktopLeftSidebar> createState() => _DesktopLeftSidebarState();
}

class _DesktopLeftSidebarState extends State<DesktopLeftSidebar> {
  CommandCenterTab? _hoverTab;

  @override
  Widget build(BuildContext context) {
    const items = <(CommandCenterTab tab, IconData icon, String label)>[
      (CommandCenterTab.home, Icons.home_rounded, 'Home'),
      (CommandCenterTab.peers, Icons.person_search_rounded, 'Peers'),
      (CommandCenterTab.marketplace, Icons.storefront_rounded, 'Marketplace'),
      (CommandCenterTab.academy, Icons.groups_rounded, 'Academy'),
      (CommandCenterTab.settings, Icons.settings_rounded, 'Settings'),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      child: Column(
        children: [
          Row(
            children: [
              const GNexusLogo(size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Command Center',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) {
            final tab = item.$1;
            final icon = item.$2;
            final label = item.$3;
            final selected = widget.selectedTab == tab;
            final hovered = _hoverTab == tab;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: MouseRegion(
                onEnter: (_) => setState(() => _hoverTab = tab),
                onExit: (_) => setState(() => _hoverTab = null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    gradient: (selected || hovered)
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryNavy,
                              AppColors.pathwayAmber,
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    color: (selected || hovered)
                        ? null
                        : AppColors.primaryNavy.withValues(alpha: 0.03),
                    border: Border.all(
                      color: (selected || hovered)
                          ? AppColors.pathwayAmber.withValues(alpha: 0.5)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    minVerticalPadding: 10,
                    leading: Icon(
                      icon,
                      size: 18,
                      color: (selected || hovered)
                          ? AppColors.surfaceWhite
                          : AppColors.primaryNavy,
                    ),
                    title: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                        color: (selected || hovered)
                            ? AppColors.surfaceWhite
                            : AppColors.textOnSurface,
                      ),
                    ),
                    onTap: () => widget.onTabSelected(tab),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          Text(
            'Hover = 200ms polish',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

