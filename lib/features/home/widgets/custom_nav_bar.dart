import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum NavItem { home, peerSearch, marketplace, studyGroups, profile }

/// Custom bottom navigation bar with 5 icons.
class CustomNavBar extends StatelessWidget {
  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavEntry> _items = [
    _NavEntry(NavItem.home, Icons.home_rounded, 'Home'),
    _NavEntry(NavItem.peerSearch, Icons.person_search_rounded, 'Mission'),
    _NavEntry(NavItem.marketplace, Icons.storefront_rounded, 'Marketplace'),
    _NavEntry(NavItem.studyGroups, Icons.groups_rounded, 'Study Groups'),
    _NavEntry(NavItem.profile, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final entry = _items[index];
              final selected = currentIndex == index;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          entry.icon,
                          size: 24,
                          color: selected
                              ? AppColors.primaryNavy
                              : AppColors.textMuted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            color: selected
                                ? AppColors.primaryNavy
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavEntry {
  const _NavEntry(this.item, this.icon, this.label);
  final NavItem item;
  final IconData icon;
  final String label;
}
