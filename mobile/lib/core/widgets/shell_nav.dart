import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/strings_tr.dart';
import '../router/route_paths.dart';

/// Bottom-navigation shell. The global FAB is mounted in app.dart's Overlay
/// so it appears on every route except /setup and /boot.
class ShellNav extends StatelessWidget {
  const ShellNav({super.key, required this.child});
  final Widget child;

  static const List<_NavItem> _items = [
    _NavItem(route: RoutePaths.home, icon: Icons.home_rounded, label: S.navHome),
    _NavItem(route: RoutePaths.projects, icon: Icons.folder_rounded, label: S.navProjects),
    _NavItem(route: RoutePaths.files, icon: Icons.description_rounded, label: S.navFiles),
    _NavItem(route: RoutePaths.chat, icon: Icons.smart_toy_rounded, label: S.navChat),
    _NavItem(route: RoutePaths.terminal, icon: Icons.terminal_rounded, label: S.navTerminal),
  ];

  int _indexFor(String location) {
    for (int i = 0; i < _items.length; i++) {
      final String path = _items[i].route;
      if (location == path) return i;
      if (path != RoutePaths.home && location.startsWith(path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final int index = _indexFor(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_items[i].route),
        destinations: [
          for (final _NavItem item in _items)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
              label: item.label,
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.route, required this.icon, required this.label});
  final String route;
  final IconData icon;
  final String label;
}
