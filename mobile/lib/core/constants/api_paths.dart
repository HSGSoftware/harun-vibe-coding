/// Single source of truth for REST endpoints. Keep in lockstep with plan.md §5.
class ApiPaths {
  const ApiPaths._();

  // System
  static const String health = '/api/health';
  static const String systemInfo = '/api/system/info';
  static const String systemStats = '/api/system/stats';
  static const String systemShutdown = '/api/system/shutdown';

  // Setup wizard
  static const String setupStatus = '/api/setup/status';
  static const String setupCliDetect = '/api/setup/cli/detect';
  static const String setupCliInstall = '/api/setup/cli/install';
  static const String setupCliLogin = '/api/setup/cli/login';
  static const String setupCliLogout = '/api/setup/cli/logout';
  static const String setupCliTest = '/api/setup/cli/test';
  static const String setupPreferences = '/api/setup/preferences';
  static const String setupComplete = '/api/setup/complete';
  static const String setupReset = '/api/setup/reset';

  // Projects
  static const String projects = '/api/projects';
  static String project(String id) => '/api/projects/$id';
  static String projectStart(String id) => '/api/projects/$id/start';
  static String projectStop(String id) => '/api/projects/$id/stop';
  static String projectRestart(String id) => '/api/projects/$id/restart';
  static String projectRefresh(String id) => '/api/projects/$id/refresh';
  static String projectLogs(String id) => '/api/projects/$id/logs';
  static String projectInput(String id) => '/api/projects/$id/input';
  static String projectExport(String id) => '/api/projects/$id/export';
  static String projectQr(String id) => '/api/projects/$id/qr';
  static const String projectImportZip = '/api/projects/import/zip';
  static const String projectImportClone = '/api/projects/import/clone';

  // Files
  static String files(String pid) => '/api/projects/$pid/files';
  static String file(String pid) => '/api/projects/$pid/file';
  static String fileNew(String pid) => '/api/projects/$pid/file/new';
  static String fileRename(String pid) => '/api/projects/$pid/file/rename';
  static String fileDuplicate(String pid) => '/api/projects/$pid/file/duplicate';
  static String search(String pid) => '/api/projects/$pid/search';
  static String replace(String pid) => '/api/projects/$pid/replace';

  // Git
  static String gitStatus(String pid) => '/api/projects/$pid/git/status';
  static String gitLog(String pid) => '/api/projects/$pid/git/log';
  static String gitDiff(String pid) => '/api/projects/$pid/git/diff';
  static String gitCommit(String pid) => '/api/projects/$pid/git/commit';
  static String gitCheckout(String pid) => '/api/projects/$pid/git/checkout';
  static String gitPull(String pid) => '/api/projects/$pid/git/pull';
  static String gitPush(String pid) => '/api/projects/$pid/git/push';
  static String gitStash(String pid) => '/api/projects/$pid/git/stash';
  static String gitRestore(String pid) => '/api/projects/$pid/git/restore';
  static const String gitBranches = '/api/git/branches';

  // Backups
  static const String backups = '/api/backups';
  static String backup(String id) => '/api/backups/$id';
  static String backupDownload(String id) => '/api/backups/$id/download';
  static String backupRestore(String id) => '/api/backups/$id/restore';
  static const String backupSettings = '/api/backups/settings';
  static const String backupCloudConnect = '/api/backups/cloud/connect';
  static const String backupCloudDisconnect = '/api/backups/cloud/disconnect';

  // AI / conversations
  static const String conversations = '/api/conversations';
  static String conversation(String id) => '/api/conversations/$id';
  static String conversationBranch(String id) => '/api/conversations/$id/branch';
  static String conversationSummarize(String id) => '/api/conversations/$id/summarize';
  static String conversationExportMd(String id) => '/api/conversations/$id/export/markdown';
  static String conversationForkTo(String id) => '/api/conversations/$id/fork-to';

  static const String aiTools = '/api/ai/tools';
  static const String aiPermissions = '/api/ai/permissions';
  static const String aiPermissionsReset = '/api/ai/permissions/reset';
  static const String aiUsage = '/api/ai/usage';
  static String aiContextFiles(String cid) => '/api/ai/context-files/$cid';
  static const String aiPrompts = '/api/ai/prompts';
  static const String aiAnalyzeError = '/api/ai/analyze-error';
  static const String aiExplainCode = '/api/ai/explain-code';
  static const String aiCommitMessage = '/api/ai/generate-commit-message';
  static const String aiReviewDiff = '/api/ai/review-diff';
  static const String aiSuggestSetup = '/api/ai/suggest-project-setup';
  static const String aiSpeechToText = '/api/ai/speech-to-text';

  // Terminal
  static const String terminals = '/api/terminals';
  static String terminal(String id) => '/api/terminals/$id';
  static String terminalResize(String id) => '/api/terminals/$id/resize';

  // Tunnel
  static String tunnelStart(String pid) => '/api/projects/$pid/tunnel/start';
  static String tunnelStop(String pid) => '/api/projects/$pid/tunnel/stop';
  static String tunnelStatus(String pid) => '/api/projects/$pid/tunnel';

  // Settings
  static const String settings = '/api/settings';
  static const String settingsTheme = '/api/settings/theme';
  static const String settingsShortcuts = '/api/settings/shortcuts';
  static const String settingsExport = '/api/settings/export';
  static const String settingsImport = '/api/settings/import';

  // Notifications
  static const String notifications = '/api/notifications';
  static String notificationRead(String id) => '/api/notifications/$id/read';
  static const String notificationReadAll = '/api/notifications/read-all';
  static String notificationDelete(String id) => '/api/notifications/$id';
  static const String notificationSettings = '/api/notifications/settings';
}
