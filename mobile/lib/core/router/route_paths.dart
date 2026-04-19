class RoutePaths {
  const RoutePaths._();

  static const String boot = '/boot';
  static const String setup = '/setup';
  static const String home = '/';
  static const String projects = '/projects';
  static const String projectNew = '/projects/new';
  static String projectDetail(String id) => '/projects/$id';
  static String projectLogs(String id) => '/projects/$id/logs';
  static String projectGit(String id) => '/projects/$id/git';

  static const String files = '/files';
  static String filesFor(String pid) => '/files/$pid';
  static String editor(String pid) => '/files/$pid/edit';

  static const String terminal = '/terminal';

  static const String chat = '/chat';
  static const String chatConversations = '/chat/conversations';
  static const String chatPrompts = '/chat/prompts';
  static const String chatUsage = '/chat/usage';
  static String chatSession(String cid) => '/chat/$cid';

  static const String backups = '/backups';
  static String backupDetail(String id) => '/backups/$id';

  static const String notifications = '/notifications';

  static const String settings = '/settings';
  static const String settingsAppearance = '/settings/appearance';
  static const String settingsEditor = '/settings/editor';
  static const String settingsTerminal = '/settings/terminal';
  static const String settingsChat = '/settings/chat';
  static const String settingsBackup = '/settings/backup';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsAi = '/settings/ai';
  static const String settingsServer = '/settings/server';
  static const String settingsAdvanced = '/settings/advanced';
  static const String settingsAbout = '/settings/about';
}
