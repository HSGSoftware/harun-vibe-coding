import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/shell_nav.dart';
import '../../features/boot/presentation/boot_page.dart';
import '../../features/setup/presentation/setup_wizard_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/projects/presentation/projects_list_page.dart';
import '../../features/projects/presentation/project_create_page.dart';
import '../../features/projects/presentation/project_detail_page.dart';
import '../../features/projects/presentation/project_logs_page.dart';
import '../../features/projects/presentation/project_git_page.dart';
import '../../features/files/presentation/file_tree_page.dart';
import '../../features/files/presentation/editor_page.dart';
import '../../features/terminal/presentation/terminal_page.dart';
import '../../features/chat/presentation/chat_home_page.dart';
import '../../features/chat/presentation/chat_session_page.dart';
import '../../features/chat/presentation/conversation_list_page.dart';
import '../../features/chat/presentation/prompt_library_page.dart';
import '../../features/chat/presentation/usage_dashboard_page.dart';
import '../../features/backup/presentation/backup_list_page.dart';
import '../../features/backup/presentation/backup_detail_page.dart';
import '../../features/notifications/presentation/notifications_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/settings/presentation/appearance_settings_page.dart';
import '../../features/settings/presentation/editor_settings_page.dart';
import '../../features/settings/presentation/terminal_settings_page.dart';
import '../../features/settings/presentation/chat_settings_page.dart';
import '../../features/settings/presentation/backup_settings_page.dart';
import '../../features/settings/presentation/notification_settings_page.dart';
import '../../features/settings/presentation/ai_settings_page.dart';
import '../../features/settings/presentation/server_settings_page.dart';
import '../../features/settings/presentation/advanced_settings_page.dart';
import '../../features/settings/presentation/about_page.dart';

import 'route_paths.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.boot,
    debugLogDiagnostics: false,
    routes: <RouteBase>[
      GoRoute(path: RoutePaths.boot, builder: (_, __) => const BootPage()),
      GoRoute(path: RoutePaths.setup, builder: (_, __) => const SetupWizardPage()),
      ShellRoute(
        builder: (context, state, child) => ShellNav(child: child),
        routes: <RouteBase>[
          GoRoute(path: RoutePaths.home, builder: (_, __) => const HomePage()),
          GoRoute(path: RoutePaths.projects, builder: (_, __) => const ProjectsListPage()),
          GoRoute(path: RoutePaths.projectNew, builder: (_, __) => const ProjectCreatePage()),
          GoRoute(
            path: '/projects/:id',
            builder: (_, st) => ProjectDetailPage(projectId: st.pathParameters['id']!),
            routes: [
              GoRoute(path: 'logs', builder: (_, st) => ProjectLogsPage(projectId: st.pathParameters['id']!)),
              GoRoute(path: 'git', builder: (_, st) => ProjectGitPage(projectId: st.pathParameters['id']!)),
            ],
          ),
          GoRoute(path: RoutePaths.files, builder: (_, __) => const FileTreePage()),
          GoRoute(
            path: '/files/:pid',
            builder: (_, st) => FileTreePage(projectId: st.pathParameters['pid']),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, st) => EditorPage(
                  projectId: st.pathParameters['pid']!,
                  path: st.uri.queryParameters['path'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(path: RoutePaths.terminal, builder: (_, __) => const TerminalPage()),
          GoRoute(path: RoutePaths.chat, builder: (_, __) => const ChatHomePage()),
          GoRoute(path: RoutePaths.chatConversations, builder: (_, __) => const ConversationListPage()),
          GoRoute(path: RoutePaths.chatPrompts, builder: (_, __) => const PromptLibraryPage()),
          GoRoute(path: RoutePaths.chatUsage, builder: (_, __) => const UsageDashboardPage()),
          GoRoute(path: '/chat/:cid', builder: (_, st) => ChatSessionPage(conversationId: st.pathParameters['cid']!)),
          GoRoute(path: RoutePaths.backups, builder: (_, __) => const BackupListPage()),
          GoRoute(path: '/backups/:id', builder: (_, st) => BackupDetailPage(backupId: st.pathParameters['id']!)),
          GoRoute(path: RoutePaths.notifications, builder: (_, __) => const NotificationsPage()),
          GoRoute(path: RoutePaths.settings, builder: (_, __) => const SettingsPage()),
          GoRoute(path: RoutePaths.settingsAppearance, builder: (_, __) => const AppearanceSettingsPage()),
          GoRoute(path: RoutePaths.settingsEditor, builder: (_, __) => const EditorSettingsPage()),
          GoRoute(path: RoutePaths.settingsTerminal, builder: (_, __) => const TerminalSettingsPage()),
          GoRoute(path: RoutePaths.settingsChat, builder: (_, __) => const ChatSettingsPage()),
          GoRoute(path: RoutePaths.settingsBackup, builder: (_, __) => const BackupSettingsPage()),
          GoRoute(path: RoutePaths.settingsNotifications, builder: (_, __) => const NotificationSettingsPage()),
          GoRoute(path: RoutePaths.settingsAi, builder: (_, __) => const AiSettingsPage()),
          GoRoute(path: RoutePaths.settingsServer, builder: (_, __) => const ServerSettingsPage()),
          GoRoute(path: RoutePaths.settingsAdvanced, builder: (_, __) => const AdvancedSettingsPage()),
          GoRoute(path: RoutePaths.settingsAbout, builder: (_, __) => const AboutPage()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Route bulunamadı: ${state.uri}')),
    ),
  );
});
