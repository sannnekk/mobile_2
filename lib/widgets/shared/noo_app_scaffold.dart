import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import 'package:mobile_2/widgets/utils/noo_theme_toggle.dart';

class NooAppScaffold extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  const NooAppScaffold({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _getCurrentIndex(GoRouterState.of(context).uri.path);

    return Scaffold(
      appBar: AppBar(
        title: NooTextTitle(title),
        actions: [NooThemeToggle(), ...(actions ?? [])],
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Padding(padding: const EdgeInsets.all(8), child: child),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/courses');
                break;
              case 1:
                context.go('/assigned_works');
                break;
              case 2:
                context.go('/calendar');
                break;
              case 3:
                context.go('/profile');
                break;
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.colorScheme.secondary,
          unselectedItemColor: theme.textTheme.labelMedium?.color,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          items: _buildNavigationItems(context, currentIndex),
        ),
      ),
    );
  }

  int _getCurrentIndex(String location) {
    switch (location) {
      case '/courses':
        return 0;
      case '/assigned_works':
        return 1;
      case '/calendar':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }

  List<BottomNavigationBarItem> _buildNavigationItems(
    BuildContext context,
    int currentIndex,
  ) {
    final navigationItems = [
      _NavigationItemData(
        iconPath: 'assets/icons/uni-hat.svg',
        label: 'Курсы',
        route: '/courses',
      ),
      _NavigationItemData(
        iconPath: 'assets/icons/list.svg',
        label: 'Работы',
        route: '/assigned_works',
      ),
      _NavigationItemData(
        iconPath: 'assets/icons/calendar.svg',
        label: 'Календарь',
        route: '/calendar',
      ),
      _NavigationItemData(
        iconPath: 'assets/icons/user.svg',
        label: 'Профиль',
        route: '/profile',
      ),
    ];

    return navigationItems.map((item) {
      return BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(
            bottom: 4.0,
          ), // Add space between icon and label
          child: SvgPicture.asset(
            item.iconPath,
            width: 28,
            height: 32,
            // Remove color filter to preserve original SVG colors
          ),
        ),
        activeIcon: Padding(
          padding: const EdgeInsets.only(
            bottom: 4.0,
          ), // Add space between icon and label
          child: SvgPicture.asset(
            item.iconPath,
            width: 28,
            height: 32,
            // Remove color filter to preserve original SVG colors
          ),
        ),
        label: item.label,
      );
    }).toList();
  }
}

class _NavigationItemData {
  final String iconPath;
  final String label;
  final String route;

  const _NavigationItemData({
    required this.iconPath,
    required this.label,
    required this.route,
  });
}
