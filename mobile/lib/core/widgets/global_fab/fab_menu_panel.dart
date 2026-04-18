import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/strings_tr.dart';
import '../../router/route_paths.dart';
import '../../theme/color_schemes.dart';
import 'fab_context_provider.dart';
import 'fab_menu_button.dart';
import 'fab_menu_toggle.dart';
import 'fab_section_header.dart';
import 'fab_status_footer.dart';

class FabMenuPanel extends ConsumerWidget {
  const FabMenuPanel({super.key, required this.onClose});
  final VoidCallback onClose;

  List<FabAction> _defaultNav(BuildContext context) => [
        FabAction(id: 'home', label: S.navHome, icon: Icons.home, color: AppColors.accent, onTap: () => context.go(RoutePaths.home)),
        FabAction(id: 'projects', label: S.navProjects, icon: Icons.folder, color: AppColors.info, onTap: () => context.go(RoutePaths.projects)),
        FabAction(id: 'chat', label: S.navChat, icon: Icons.smart_toy, color: AppColors.purple, onTap: () => context.go(RoutePaths.chat)),
        FabAction(id: 'terminal', label: S.navTerminal, icon: Icons.terminal, color: AppColors.success, onTap: () => context.go(RoutePaths.terminal)),
      ];

  List<FabAction> _defaultActions(BuildContext context) => [
        FabAction(id: 'new_project', label: S.fabNewProject, icon: Icons.add_box, color: AppColors.success, onTap: () => context.go(RoutePaths.projectNew)),
        FabAction(id: 'new_chat', label: S.fabNewChat, icon: Icons.chat_bubble, color: AppColors.purple, onTap: () => context.go(RoutePaths.chat)),
        FabAction(id: 'tunnel_share', label: S.fabTunnelShare, icon: Icons.share, color: AppColors.magenta, enabled: false),
        FabAction(id: 'backup_now', label: S.fabBackupNow, icon: Icons.save, color: AppColors.warning, onTap: () => context.go(RoutePaths.backups)),
      ];

  List<FabAction> _defaultStatus(BuildContext context) => [
        FabAction(id: 'dark', label: S.fabDarkMode, icon: Icons.dark_mode, color: AppColors.info, toggled: Theme.of(context).brightness == Brightness.dark),
        FabAction(id: 'mute', label: S.fabMute, icon: Icons.notifications_off, color: AppColors.warning, toggled: false),
        FabAction(id: 'dev_server', label: S.fabDevServer, icon: Icons.bolt, color: AppColors.success, toggled: false),
        FabAction(id: 'stop_all', label: S.fabEmergencyStop, icon: Icons.stop_circle, color: AppColors.danger),
      ];

  List<FabAction> _defaultSystem(BuildContext context) => [
        FabAction(id: 'stats', label: S.homeSystemStats, icon: Icons.analytics, color: AppColors.info),
        FabAction(id: 'reconnect', label: S.fabReconnect, icon: Icons.sync, color: AppColors.warning),
        FabAction(id: 'global_search', label: S.fabGlobalSearch, icon: Icons.search, color: AppColors.cyan),
        FabAction(id: 'settings', label: S.settingsTitle, icon: Icons.settings, color: AppColors.onSurfaceDim, onTap: () => context.go(RoutePaths.settings)),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FabOverride override = ref.watch(fabContextProvider);
    final List<FabAction> nav = override.nav ?? _defaultNav(context);
    final List<FabAction> actions = override.actions ?? _defaultActions(context);
    final List<FabAction> status = override.status ?? _defaultStatus(context);
    final List<FabAction> system = override.system ?? _defaultSystem(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 260,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainer,
            ],
          ),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          boxShadow: const [
            BoxShadow(color: Color(0xAA000000), blurRadius: 24, offset: Offset(0, 6)),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const FabSectionHeader(title: S.fabQuickOpen),
              _row(nav),
              const FabSectionHeader(title: S.fabActions),
              _row(actions),
              const FabSectionHeader(title: S.fabStatus),
              _row(status, toggles: true),
              const FabSectionHeader(title: S.fabSystem),
              _row(system),
              const SizedBox(height: 12),
              const FabStatusFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(List<FabAction> items, {bool toggles = false}) {
    return SizedBox(
      height: 92,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final action in items)
            (toggles && action.toggled != null)
                ? FabMenuToggle(action: action, onClose: onClose)
                : FabMenuButton(action: action, onClose: onClose),
        ],
      ),
    );
  }
}
