/// Single source of truth for all user-facing Turkish strings.
/// Code language (variable names, comments) stays English; UI language is Turkish.
/// See skill.md §6 for tone rules.
class S {
  const S._();

  // Generic
  static const String appName = 'Harun Vibe Coding';
  static const String ok = 'Tamam';
  static const String cancel = 'İptal';
  static const String save = 'Kaydet';
  static const String back = 'Geri';
  static const String next = 'İleri';
  static const String retry = 'Yeniden Dene';
  static const String close = 'Kapat';
  static const String open = 'Aç';
  static const String skip = 'Atla';
  static const String start = 'Başlat';
  static const String stop = 'Durdur';
  static const String restart = 'Yeniden Başlat';
  static const String remove = 'Sil';
  static const String edit = 'Düzenle';
  static const String rename = 'Yeniden Adlandır';
  static const String share = 'Paylaş';
  static const String confirm = 'Onayla';
  static const String done = 'Bitti';
  static const String loading = 'Yükleniyor…';
  static const String refresh = 'Yenile';
  static const String search = 'Ara';

  // Status
  static const String connected = 'Bağlandı';
  static const String connecting = 'Bağlanılıyor…';
  static const String disconnected = 'Bağlantı koptu';
  static const String serverRunning = 'Sunucu çalışıyor';
  static const String serverStarting = 'Sunucu başlatılıyor…';
  static const String serverError = 'Sunucuya bağlanılamadı';
  static const String ready = 'Hazır';

  // Errors
  static const String errNetwork = 'Bağlanamadım. Tekrar deneyelim mi?';
  static const String errUnknown = 'Bir şeyler ters gitti. Tekrar dene.';
  static const String errTimeout = 'Zaman aşımı oldu.';
  static const String errNotFound = 'Bulunamadı.';

  // Boot
  static const String bootStarting = 'Sunucu başlatılıyor…';
  static const String bootConnecting = 'Bağlanılıyor…';
  static const String bootReady = 'Hazır';
  static const String bootTermuxMissing = 'Termux bulunamadı';
  static const String bootOpenTermux = 'Termux\'u Aç';
  static const String bootCheckAgain = 'Tekrar Kontrol Et';

  // Setup wizard
  static const String setupWelcomeTitle = 'Harun Vibe Coding\'e hoş geldin';
  static const String setupWelcomeBody =
      'Telefonunda tam bir AI-destekli mobil IDE. Hazırlık 2 dakika sürer.';
  static const String setupStart = 'Başlayalım';
  static const String setupTermuxTitle = 'Termux kontrolü';
  static const String setupTermuxMissing = 'Termux kurulu değil';
  static const String setupTermuxNotConfigured = 'Termux yapılandırılmamış';
  static const String setupTermuxReady = 'Termux hazır';
  static const String setupAllowExternalHelp =
      'Termux\'ta şu adımları uygula:\n'
      '1. Termux\'u aç\n'
      '2. nano ~/.termux/termux.properties\n'
      '3. allow-external-apps = true satırını ekle\n'
      '4. Ctrl+X → Y → Enter\n'
      '5. Termux\'u kapatıp yeniden aç';
  static const String setupPermissionsTitle = 'İzinler';
  static const String setupAiTitle = 'AI Asistanını Bağla';
  static const String setupAiSubtitle =
      'Claude ve Gemini hesabınla giriş yaparsın, API anahtarı gerekmez. '
      'En az bir sağlayıcı yeterli.';
  static const String setupAiClaudeTitle = 'Claude (Anthropic hesabın)';
  static const String setupAiClaudeSubtitle = 'Claude Pro, Max veya Team aboneliği gerekir.';
  static const String setupAiGeminiTitle = 'Gemini (Google hesabın)';
  static const String setupAiInstall = 'Otomatik Kur';
  static const String setupAiLogin = 'Giriş Yap';
  static const String setupAiLogout = 'Çıkış Yap';
  static const String setupAiTest = 'Test Et';
  static const String setupPrefsTitle = 'Tercihler';
  static const String setupFirstProjectTitle = 'İlk Projen';
  static const String setupFirstProjectEmpty = 'Boş Proje';
  static const String setupFirstProjectClone = 'GitHub\'dan Klonla';
  static const String setupDoneTitle = 'Her şey hazır!';
  static const String setupDoneSubtitle =
      'Bundan sonra her şeyi Harun Vibe Coding içinden yapabilirsin. Terminale hiç dokunmana gerek yok.';
  static const String setupGoToApp = 'Uygulamaya Git';

  // Nav
  static const String navHome = 'Ana';
  static const String navProjects = 'Projeler';
  static const String navFiles = 'Dosyalar';
  static const String navChat = 'AI';
  static const String navTerminal = 'Terminal';

  // Home
  static const String homeActiveProjects = 'Aktif Projeler';
  static const String homeQuickActions = 'Hızlı Eylemler';
  static const String homeRecentChats = 'Son Sohbetler';
  static const String homeSystemStats = 'Sistem';
  static const String homeEmpty = 'Henüz proje yok. İlk projeni oluştur.';

  // Projects
  static const String projectsTitle = 'Projeler';
  static const String projectsFilterAll = 'Tümü';
  static const String projectsFilterRunning = 'Çalışanlar';
  static const String projectsFilterFavorites = 'Favoriler';
  static const String projectsFilterRecent = 'Son Açılanlar';
  static const String projectNew = 'Yeni Proje';
  static const String projectEmpty = 'Boş Proje';
  static const String projectClone = 'GitHub\'dan Klon';
  static const String projectZip = 'ZIP\'ten Yükle';
  static const String statusRunning = 'Çalışıyor';
  static const String statusStarting = 'Başlatılıyor…';
  static const String statusStopped = 'Durdu';
  static const String statusError = 'Hata';

  // Files
  static const String filesTitle = 'Dosyalar';
  static const String filesUnsaved = 'Kaydedilmemiş değişiklikler var';
  static const String filesQuickOpen = 'Hızlı Aç';

  // Terminal
  static const String terminalNewTab = 'Yeni Sekme';
  static const String terminalCloseAll = 'Tüm Terminalleri Kapat';

  // Chat
  static const String chatInputHint = 'AI\'a sor…';
  static const String chatThinking = 'Düşünüyor…';
  static const String chatSend = 'Gönder';
  static const String chatNew = 'Yeni Sohbet';
  static const String chatAbort = 'Durdur';
  static const String permissionTitle = 'AI izin istiyor';
  static const String permissionAllow = 'İzin Ver';
  static const String permissionDeny = 'Reddet';
  static const String permissionAllowAlways = 'Her zaman izin ver';
  static const String permissionDenyAlways = 'Her zaman reddet';

  // Settings
  static const String settingsTitle = 'Ayarlar';
  static const String settingsAppearance = 'Görünüm';
  static const String settingsEditor = 'Editör';
  static const String settingsTerminal = 'Terminal';
  static const String settingsChat = 'Sohbet';
  static const String settingsBackup = 'Yedekleme';
  static const String settingsNotifications = 'Bildirimler';
  static const String settingsAi = 'AI';
  static const String settingsServer = 'Sunucu';
  static const String settingsAdvanced = 'Gelişmiş';
  static const String settingsAbout = 'Hakkında';

  // FAB menu
  static const String fabQuickOpen = 'Hızlı Aç';
  static const String fabActions = 'Eylemler';
  static const String fabStatus = 'Durum';
  static const String fabSystem = 'Sistem';
  static const String fabDarkMode = 'Koyu';
  static const String fabMute = 'Sessiz';
  static const String fabDevServer = 'Dev Server';
  static const String fabEmergencyStop = 'Acil Dur';
  static const String fabReconnect = 'Yeniden Bağlan';
  static const String fabGlobalSearch = 'Global Ara';
  static const String fabTunnelShare = 'Tunnel Paylaş';
  static const String fabBackupNow = 'Yedek Al';
  static const String fabNewProject = 'Yeni Proje';
  static const String fabNewChat = 'Yeni Sohbet';
}
