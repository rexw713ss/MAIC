import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.brandTitle = 'VitalClarity',
    this.avatarUrl,
  });

  final String title;
  final String brandTitle;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerPadding),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF3F4F8)),
        ),
      ),
      child: Row(
        children: [
          _Avatar(url: avatarUrl, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title.isEmpty ? brandTitle : title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(CupertinoIcons.bell_fill, color: AppTheme.primary, size: 18),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceContainer,
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? const Icon(CupertinoIcons.person_fill, size: 18, color: AppTheme.outline)
          : Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                CupertinoIcons.person_fill,
                size: 18,
                color: AppTheme.outline,
              ),
            ),
    );
  }
}

class PrimaryCard extends StatelessWidget {
  const PrimaryCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }
}

CupertinoTabBar buildAppTabBar() {
  return CupertinoTabBar(
    height: 72,
    backgroundColor: CupertinoColors.white,
    activeColor: AppTheme.primary,
    inactiveColor: AppTheme.outline,
    items: [
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.house_fill), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.calendar), label: 'Schedule'),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.add_circled), label: 'Add'),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.heart_fill), label: 'Health'),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'Settings'),
    ],
  );
}
