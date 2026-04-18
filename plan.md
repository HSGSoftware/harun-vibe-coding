# Harun Vibe Coding — Flutter + Go Mobil IDE İnşa Planı

> **Bu dosya vibe-coding araçları için hazırlanmıştır. Tek başına, ek prompt olmadan sıfırdan uygulanabilir. Bu plana harfiyen uyun. Mevcut bir kod tabanı YOKTUR — her şey sıfırdan inşa edilecektir.**

---

## İçindekiler

0. Proje Kimliği ve Kesin Kurallar
1. Vizyon ve Kullanım Senaryoları
2. Üst Düzey Mimari
3. Teknoloji Yığını — Kesin Kararlar
4. Backend (Go) — Kapsamlı Tasarım
5. API Sözleşmesi — Tüm Endpoint'ler
6. WebSocket Protokolü — Mesaj Formatı
7. Flutter Uygulaması — Mimari ve Dizin Yapısı
8. Android Native — Termux Köprüsü ve Bildirim
9. İlk Açılış Kurulum Sihirbazı
10. Ekran-Ekran UX Spesifikasyonu
11. Vibe Coding Sohbet Bölümü — Gelişmiş Özellikler
12. Yedekleme Sistemi
13. Bildirim Sistemi
14. Terminal (Gömülü)
15. Monaco Kod Editörü Entegrasyonu
16. Edge Case'ler ve Çözümleri
17. Performans Hedefleri
18. Faz-Faz Yol Haritası
19. Teslim Sırası ve Yapısal Kurallar

---

## 0. Proje Kimliği ve Kesin Kurallar

| Alan | Değer |
|---|---|
| **Uygulama adı** | Harun Vibe Coding |
| **Paket adı** | `com.harun.vibecoding` |
| **Frontend** | Flutter 3.24+ / Dart 3.5+ |
| **Backend** | Go 1.22+ — tek binary, Termux'ta çalışır |
| **minSdk / targetSdk** | 26 / 34 |
| **Mimari** | Clean architecture + Riverpod 2 (code-gen) + go_router + Freezed |
| **UI dili** | Türkçe (kullanıcıya görünen her şey) |
| **Kod dili** | İngilizce (değişken, sınıf, yorum, dosya adı) |
| **Tema** | Material 3, dark-first, accent `#5468ff` |
| **Hedef cihaz** | Samsung S23 Ultra ve benzeri modern Android telefonlar |
| **Dağıtım** | Yayınlanmayacak — kişisel kullanım, kendi APK'sı |

### Kesin Sınırlar (Bunlar Yapılmayacak)

- **`flutter build`, `flutter pub get`, `flutter run`, `go build`, `go run` gibi komutlar planda YER ALMAYACAK.** Yalnızca kaynak dosya içerikleri teslim edilir. Kullanıcı build işlemini kendi halleder.
- **Play Store / F-Droid metadata, signing, keystore, release workflow yok** — uygulama yayınlanmayacak.
- **Mock / fake / demo veri yok.** Tüm veri gerçek backend'den gelir. Backend yoksa kullanıcıya kurulum sihirbazı gösterilir.
- **WebView istisnası yalnızca Monaco kod editörü için.** Başka hiçbir yerde WebView kullanılmaz.
- **Kullanıcı Termux'a hiç girmek zorunda kalmaz.** Termux yalnızca Go binary'sini barındıran bir runtime host'udur. Tüm etkileşim Flutter uygulaması üzerinden olur.
- **Claude Code CLI ve Gemini CLI ZORUNLUDUR.** Bu CLI'lar OAuth / hesap login'i ile çalışır, API key kullanmaz. Kullanıcı Claude Pro/Max ve Gemini hesaplarıyla giriş yapar. Backend bu CLI'ları subprocess olarak çağırır. Detay: Section 11.0.

### Dağıtılmayacak Unsurlar

Bu plan yalnızca **kaynak kod teslim sözleşmesidir**. Sonuç olarak vibe coder şunları üretir:
- Tam `backend/` dizini (Go kaynak kodu)
- Tam `mobile/` dizini (Flutter kaynak kodu)
- Tam `android/` native dosyaları (Kotlin, XML, Gradle config dosyaları — ama build komutları çalıştırılmaz)
- `assets/` (Monaco dağıtımı, fontlar, Lottie animasyonları)
- README.md (kullanıcı için kurulum notları)

---

## 1. Vizyon ve Kullanım Senaryoları

### Vizyon Cümlesi

**Harun Vibe Coding, Android telefonunda yaşayan bağımsız bir AI-first mobil IDE'dir. Kullanıcı, tek dokunuşla proje açar, AI asistanla konuşarak kod yazar, gerçek terminalde komut çalıştırır, dev sunucusunu başlatır, public URL paylaşır — her şey tek uygulamada.**

### Birincil Kullanım Senaryoları

**Senaryo 1: Sıfırdan proje**
1. Kullanıcı + butonuna basar
2. "Boş proje" → isim + dil seçer → oluşturulur
3. AI sekmesine geçer
4. "Bir todo listesi uygulaması yaz, React + Vite + TypeScript" yazar
5. AI dosyaları oluşturur (kullanıcı her değişiklik için onay verir)
6. "Başlat" butonuna basar → dev server ayağa kalkar, QR kod gösterilir
7. "Tunnel aç" → public URL üretilir, telefondan paylaşır

**Senaryo 2: GitHub'dan klonla**
1. + butonuna basar → "Git repo"
2. URL yapıştırır, branch seçer
3. AI otomatik `README.md`'yi okur, "Setup'ı tamamla" önerir
4. AI gerekli bağımlılıkları kurar (`npm install`, `pip install`, vs.)
5. Dev server'ı başlatır

**Senaryo 3: Debugging**
1. Dev server'da hata alır
2. Log sekmesinde hata satırı üzerine uzun basar → "AI'a sor"
3. AI hatayı analiz eder, ilgili dosyayı okur, düzeltme önerir
4. Diff viewer'da değişikliği görür, "Uygula"ya basar
5. Dev server otomatik yeniden başlar

**Senaryo 4: Karanlıkta yazılım**
1. Yatağa uzanmış, telefon elinde
2. Uzun prompt yazmak istemiyor → mikrofon butonuna basar, sesli konuşur
3. AI çalışırken telefon ekranı söner, kullanıcı gözlerini kapatır
4. AI işini bitirince bildirim çalar, kullanıcı kaldığı yerden devam eder

### Kullanıcı Beklentileri (Vizyon Rehberi)

- **Her şey tek elle kullanılabilir** (telefon dikey modda)
- **Hiçbir özellik için terminalden bir komut yazmaya mecbur kalınmaz**
- **AI asistan her adımda yardıma hazır** — sadece sohbet sekmesinde değil, her ekranda
- **Offline durumda da temel özellikler çalışır** (dosya düzenleme, proje başlatma, sadece AI çevrim içi gerektirir)
- **Pil dostu** — arka planda çalışırken düşük tüketim
- **Hata toleransı yüksek** — ağ koparsa, sunucu düşerse, Termux öldürülürse kendi kendini toparlar

---

## 2. Üst Düzey Mimari

```
┌───────────────────────────────────────────────────────────────┐
│              Flutter App (com.harun.vibecoding)               │
│                                                               │
│  ┌─────────────────┐  ┌───────────────────────────────────┐   │
│  │  Presentation   │  │         Native (Kotlin)           │   │
│  │  - Riverpod 2   │  │  - TermuxBridge                   │   │
│  │  - go_router    │  │  - ServerLifecycleService         │   │
│  │  - Freezed      │  │  - NotificationBridge             │   │
│  └────────┬────────┘  │  - SpeechToTextBridge             │   │
│           │           │  - ScreenshotBridge               │   │
│  ┌────────▼────────┐  └────────────┬──────────────────────┘   │
│  │     Domain      │               │ MethodChannel            │
│  │  (Entities +    │               │                          │
│  │   UseCases)     │               ▼                          │
│  └────────┬────────┘   ┌─────────────────────────┐            │
│           │            │   Android System APIs   │            │
│  ┌────────▼────────┐   │  - RunCommandService    │            │
│  │      Data       │   │  - ForegroundService    │            │
│  │  - ApiClient    │   │  - NotificationManager  │            │
│  │  - WsClient     │   │  - SpeechRecognizer     │            │
│  │  - Repos impl   │   │  - MediaProjection      │            │
│  └────────┬────────┘   └────────────┬────────────┘            │
└───────────┼──────────────────────────┼────────────────────────┘
            │ HTTP + WebSocket         │ Intent
            ▼                          ▼
     ┌─────────────────────────────────────────┐
     │   Termux (Go binary çalışır)            │
     │   ┌─────────────────────────────────┐   │
     │   │  Harun Vibe Coding Server       │   │
     │   │  (Go 1.22, single binary)       │   │
     │   │                                 │   │
     │   │  - Gin (HTTP REST)              │   │
     │   │  - gorilla/websocket            │   │
     │   │  - creack/pty (terminal)        │   │
     │   │  - go-git (version control)    │   │
     │   │  - fsnotify (file watch)        │   │
     │   │  - Anthropic + Google AI SDK    │   │
     │   └─────────────────────────────────┘   │
     │                                         │
     │   Port: 8080 (varsayılan)               │
     └─────────────────────────────────────────┘
```

### Katmanlar

1. **Presentation (Flutter)** — Widget'lar, Riverpod providers, go_router ile navigasyon. Hiçbir iş mantığı içermez.
2. **Domain (Flutter)** — Saf Dart. Entity'ler, UseCase'ler, Repository arayüzleri. Dış bağımlılık yok.
3. **Data (Flutter)** — ApiClient (Dio), WsClient (web_socket_channel), Repository implementasyonları, DTO'lar, Mapper'lar.
4. **Native (Kotlin)** — Sadece Android'in zorunlu kıldığı işler: foreground service, Termux intent, bildirim, ses tanıma, ekran görüntüsü.
5. **Backend (Go)** — REST + WebSocket server. Dosya sistemi, PTY, Git, AI API'leri proxy'si, yedekleme.

### Mesaj Akışı Örneği — Kullanıcı AI'a "Dosyaları listele" diyor

```
1. [Flutter] ChatInputBar → onSubmit("Dosyaları listele")
2. [Flutter] ChatRepository.sendMessage(sid, text)
3. [Flutter] WsClient.send({"type":"chat.input","sid":"x8","text":"Dosyaları listele"})
4. [Go Backend] WebSocket handler → AIService.chat(sid, text)
5. [Go Backend] Anthropic API'ye stream request → chunks gelmeye başlar
6. [Go Backend] Her chunk → WebSocket'e push: {"type":"chat.chunk","kind":"text","text":"Elbette..."}
7. [Flutter] WsClient.stream → ChatProvider → UI'da incremental render
8. [Go Backend] Tool call gelirse: {"type":"chat.tool_call","name":"list_files","input":{...}}
9. [Flutter] Permission dialog göster → kullanıcı "İzin Ver"
10. [Go Backend] Tool'u çalıştır → sonucu Anthropic'e geri gönder → stream devam
11. [Go Backend] Tamamlanınca: {"type":"chat.done","stats":{...}}
```

---

## 3. Teknoloji Yığını — Kesin Kararlar

### Backend — Go

Go seçilmesinin nedenleri:
- **Tek binary**: bağımlılık cehennemi yok, Termux'ta `pkg install golang` ile derlenir
- **Native performans**: 100+ eşzamanlı WebSocket + 10 PTY yüksüz koşar
- **Düşük bellek**: ~30MB idle, ~80MB yüklü
- **Goroutine + channel**: eşzamanlılık birinci sınıf
- **Test edilmiş ekosistem**: gorilla/websocket, creack/pty, go-git endüstri standardı
- **Hızlı derleme**: Termux'ta bile bir kaç saniye

### Ana Bağımlılıklar (backend/go.mod)

| Paket | Amaç |
|---|---|
| `github.com/gin-gonic/gin` | HTTP router + middleware |
| `github.com/gorilla/websocket` | WebSocket server |
| `github.com/creack/pty` | Terminal PTY bağlantıları |
| `github.com/go-git/go-git/v5` | Git işlemleri (checkpoint, diff, log) |
| `github.com/fsnotify/fsnotify` | Dosya sistemi izleme |
| — | **Claude ve Gemini doğrudan SDK ile değil, CLI subprocess ile çağrılır. Bkz. Section 11.0.** |
| `github.com/go-resty/resty/v2` | HTTP istemci (webhook, cloudflared API) |
| `github.com/google/uuid` | UUID üretimi |
| `gopkg.in/yaml.v3` | Config dosyaları |
| `github.com/joho/godotenv` | .env desteği |
| `github.com/rs/zerolog` | Yapılandırılmış loglama |
| `github.com/mattn/go-sqlite3` | Yerel DB (sohbet geçmişi, ayarlar) |
| `github.com/pressly/goose/v3` | DB migration |
| `golang.org/x/crypto` | Genel şifreleme (yerel token, hassas ayarlar) |
| `github.com/stretchr/testify` | Test framework |

### Frontend — Flutter

| Paket | Versiyon | Amaç |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | State management |
| `riverpod_annotation` | ^2.3.5 | Code generation |
| `go_router` | ^14.2.7 | Navigasyon |
| `dio` | ^5.7.0 | HTTP istemci |
| `web_socket_channel` | ^3.0.1 | WebSocket |
| `freezed_annotation` | ^2.4.4 | Immutable model |
| `json_annotation` | ^4.9.0 | JSON serialization |
| `flutter_hooks` | ^0.20.5 | Hook API |
| `hooks_riverpod` | ^2.5.1 | Riverpod + hooks |
| `flutter_inappwebview` | ^6.1.5 | Monaco editör |
| `xterm` | ^4.0.0 | Terminal emulator |
| `flutter_markdown` | ^0.7.4 | Sohbet markdown render |
| `flutter_highlight` | ^0.7.0 | Kod blok renklendirme |
| `flutter_local_notifications` | ^17.2.3 | Bildirimler |
| `permission_handler` | ^11.3.1 | Runtime izin |
| `connectivity_plus` | ^6.0.5 | Ağ durumu |
| `battery_plus` | ^6.0.3 | Pil bilgisi |
| `package_info_plus` | ^8.0.2 | Uygulama bilgisi |
| `device_info_plus` | ^10.1.2 | Cihaz bilgisi |
| `speech_to_text` | ^7.0.0 | Sesli giriş |
| `image_picker` | ^1.1.2 | Galeri/kamera |
| `share_plus` | ^10.0.2 | Paylaşım |
| `file_picker` | ^8.1.2 | Dosya seçici |
| `path_provider` | ^2.1.4 | Yerel yol |
| `shared_preferences` | ^2.3.2 | Ayarlar |
| `flutter_secure_storage` | ^9.2.2 | Yerel server token ve hassas ayarları güvenli saklama |
| `animations` | ^2.0.11 | Geçişler |
| `flutter_staggered_animations` | ^1.1.1 | Liste animasyonları |
| `lottie` | ^3.1.2 | Lottie animasyonlar |
| `google_fonts` | ^6.2.1 | Fontlar |
| `fl_chart` | ^0.68.0 | Grafikler (token maliyeti) |
| `qr_flutter` | ^4.1.0 | QR kod (tunnel paylaşımı) |
| `url_launcher` | ^6.3.0 | Tarayıcı/uygulama açma |
| `flutter_foreground_task` | ^8.10.0 | Foreground service |
| `intl` | ^0.19.0 | Yerelleştirme / tarih |
| `rxdart` | ^0.28.0 | Stream yardımcılar |
| `logger` | ^2.4.0 | Loglama |
| `uuid` | ^4.5.0 | UUID |

### Dev Bağımlılıklar

| Paket | Versiyon |
|---|---|
| `flutter_lints` | ^5.0.0 |
| `build_runner` | ^2.4.13 |
| `riverpod_generator` | ^2.4.3 |
| `freezed` | ^2.5.7 |
| `json_serializable` | ^6.8.0 |
| `custom_lint` | ^0.6.7 |
| `riverpod_lint` | ^2.3.13 |

---

## 4. Backend (Go) — Kapsamlı Tasarım

### 4.1 Dizin Yapısı

```
backend/
├── cmd/
│   └── server/
│       └── main.go                    # Giriş noktası
├── internal/
│   ├── config/
│   │   ├── config.go                  # YAML + env yükleyici
│   │   └── defaults.go
│   ├── server/
│   │   ├── server.go                  # Gin router setup
│   │   ├── middleware.go              # Logging, CORS, auth
│   │   └── graceful_shutdown.go
│   ├── api/                           # HTTP handler'lar
│   │   ├── projects.go
│   │   ├── files.go
│   │   ├── git.go
│   │   ├── backup.go
│   │   ├── ai.go
│   │   ├── terminal.go
│   │   ├── tunnel.go
│   │   ├── settings.go
│   │   ├── system.go
│   │   └── health.go
│   ├── ws/                            # WebSocket katmanı
│   │   ├── hub.go                     # Tüm bağlantıları yönetir
│   │   ├── client.go                  # Tek bir istemci bağlantısı
│   │   ├── channels.go                # chat, terminal, events, fs
│   │   ├── chat_handler.go
│   │   ├── terminal_handler.go
│   │   ├── events_handler.go          # Bildirim push
│   │   └── fs_handler.go              # Dosya değişim push
│   ├── domain/                        # İş mantığı (dış bağımlılık yok)
│   │   ├── project/
│   │   │   ├── project.go
│   │   │   ├── service.go
│   │   │   └── env_detector.go        # package.json, pubspec.yaml vs.
│   │   ├── runner/
│   │   │   ├── runner.go              # Dev server process yönetimi
│   │   │   ├── process.go
│   │   │   └── flutter.go             # Flutter özel (ready detection)
│   │   ├── fs/
│   │   │   ├── tree.go                # Dosya ağacı
│   │   │   ├── watch.go               # fsnotify wrapper
│   │   │   └── search.go              # İçerik arama (grep)
│   │   ├── git/
│   │   │   ├── service.go
│   │   │   ├── checkpoint.go          # Otomatik commit
│   │   │   ├── diff.go
│   │   │   └── history.go
│   │   ├── backup/
│   │   │   ├── service.go
│   │   │   ├── local_zip.go
│   │   │   ├── cloud_gdrive.go        # Opsiyonel
│   │   │   └── retention.go           # Eski yedek silme
│   │   ├── ai/
│   │   │   ├── service.go             # Anthropic + Gemini unified
│   │   │   ├── anthropic.go
│   │   │   ├── gemini.go
│   │   │   ├── tools.go               # Tool tanımları (read_file, write_file, bash, ...)
│   │   │   ├── tool_executor.go
│   │   │   ├── context_builder.go     # Dosya bağlamı, @mention
│   │   │   ├── token_counter.go
│   │   │   └── cost_tracker.go
│   │   ├── terminal/
│   │   │   ├── session.go             # PTY session
│   │   │   └── manager.go
│   │   └── tunnel/
│   │       ├── cloudflared.go
│   │       └── ngrok.go               # Opsiyonel fallback
│   ├── storage/                       # Veri kalıcılığı
│   │   ├── sqlite.go                  # DB bağlantısı
│   │   ├── migrations/
│   │   │   ├── 001_init.sql
│   │   │   ├── 002_projects.sql
│   │   │   ├── 003_conversations.sql
│   │   │   ├── 004_settings.sql
│   │   │   ├── 005_backups.sql
│   │   │   └── 006_prompts_library.sql
│   │   ├── projects_repo.go
│   │   ├── conversations_repo.go
│   │   ├── settings_repo.go
│   │   ├── backups_repo.go
│   │   ├── prompts_repo.go
│   │   └── usage_repo.go              # Token maliyet izleme
│   ├── notifications/                 # Bildirim üretimi (Flutter'a push)
│   │   ├── dispatcher.go
│   │   ├── rules.go                   # Hangi olaylar bildirim
│   │   └── types.go
│   ├── security/
│   │   ├── keyring.go                 # Yerel token şifreleme (server auth, session id)
│   │   └── token.go                   # İsteğe bağlı basit auth
│   └── util/
│       ├── env.go                     # Termux ortam tespiti
│       ├── paths.go
│       ├── zip.go
│       ├── fs_safe.go                 # Path traversal koruması
│       └── time.go
├── pkg/                               # Dışa açık yardımcılar (az)
│   └── version/
│       └── version.go
├── schema/                            # OpenAPI / JSON Schema
│   ├── openapi.yaml
│   └── ws-protocol.md
├── scripts/
│   ├── build.sh                       # Termux'ta build
│   └── install.sh                     # İlk kurulum
├── go.mod
├── go.sum
└── README.md
```

### 4.2 Config Dosyası

**Yol:** `~/.harun-vibe/config.yaml` (Termux'ta `~` → `/data/data/com.termux/files/home`)

```yaml
server:
  host: 0.0.0.0
  port: 8080
  cors_origins: ["*"]
  log_level: info
  log_file: ~/.harun-vibe/logs/server.log

paths:
  projects_dir: ~/HarunVibeCoding/projects
  backups_dir: ~/HarunVibeCoding/backups
  data_dir: ~/.harun-vibe

database:
  path: ~/.harun-vibe/data.db

ai:
  # API key KULLANILMAZ. Claude ve Gemini CLI'ları OAuth/hesap login'i ile kullanılır.
  providers:
    claude:
      cli_path: ""              # auto-detect: `which claude` (Claude Code CLI)
      default_model: claude-sonnet-4-5
      extended_thinking: false
      login_status: unknown     # "logged_in" | "logged_out" | "unknown", runtime belirlenir
    gemini:
      cli_path: ""              # auto-detect: `which gemini` (Gemini CLI)
      default_model: gemini-2.5-pro
      login_status: unknown
  max_output_tokens: 8192
  timeout_seconds: 300          # uzun iş timeout'u
  streaming: true               # CLI'lar stream desteklediğinde

backup:
  auto_enabled: true
  interval_minutes: 30
  max_local_backups: 20
  git_checkpoint: true
  cloud_enabled: false
  cloud_provider: ""              # "gdrive" | "dropbox"

notifications:
  enabled: true
  ai_response_sound: true
  server_error_vibrate: true
  tunnel_ready_alert: true
  backup_complete_silent: true

tunnel:
  provider: cloudflared           # "cloudflared" | "ngrok"
  cloudflared_path: ""            # auto-detect if empty
```

### 4.3 Domain Modelleri (Go struct)

```go
// internal/domain/project/project.go
type Project struct {
    ID          string    `json:"id"`
    Name        string    `json:"name"`
    Path        string    `json:"path"`
    Env         string    `json:"env"`          // flutter, nodejs, python, react, ...
    Port        int       `json:"port"`
    EntryCmd    string    `json:"entry_cmd"`
    Source      string    `json:"source"`        // git, zip, empty
    GitRepo     string    `json:"git_repo,omitempty"`
    GitBranch   string    `json:"git_branch,omitempty"`
    Group       string    `json:"group,omitempty"`
    Favorite    bool      `json:"favorite"`
    LastOpened  time.Time `json:"last_opened"`
    CreatedAt   time.Time `json:"created_at"`
    Status      string    `json:"status"`        // runtime only: stopped, starting, running, error
    RunningPort int       `json:"running_port,omitempty"`
    TunnelURL   string    `json:"tunnel_url,omitempty"`
}

// internal/domain/ai/conversation.go
type Conversation struct {
    ID        string    `json:"id"`
    ProjectID string    `json:"project_id"`
    Provider  string    `json:"provider"`        // "anthropic" | "google"
    Model     string    `json:"model"`
    Title     string    `json:"title"`
    CreatedAt time.Time `json:"created_at"`
    UpdatedAt time.Time `json:"updated_at"`
    Messages  []Message `json:"messages,omitempty"`
    Stats     Stats     `json:"stats"`
}

type Message struct {
    ID        string         `json:"id"`
    Role      string         `json:"role"`        // user, assistant, tool_call, tool_result, system
    Content   []ContentBlock `json:"content"`
    Timestamp time.Time      `json:"timestamp"`
}

type ContentBlock struct {
    Type       string          `json:"type"`      // text, thinking, tool_use, tool_result, image
    Text       string          `json:"text,omitempty"`
    ToolUseID  string          `json:"tool_use_id,omitempty"`
    ToolName   string          `json:"tool_name,omitempty"`
    Input      json.RawMessage `json:"input,omitempty"`
    Output     string          `json:"output,omitempty"`
    IsError    bool            `json:"is_error,omitempty"`
    ImageURL   string          `json:"image_url,omitempty"`
    ImageData  string          `json:"image_data,omitempty"`  // base64
}

type Stats struct {
    InputTokens  int     `json:"input_tokens"`
    OutputTokens int     `json:"output_tokens"`
    CacheTokens  int     `json:"cache_tokens"`
    TotalCost    float64 `json:"total_cost"`
    DurationMs   int64   `json:"duration_ms"`
    NumTurns     int     `json:"num_turns"`
}

// internal/domain/backup/backup.go
type Backup struct {
    ID         string    `json:"id"`
    ProjectID  string    `json:"project_id"`
    Type       string    `json:"type"`           // "local_zip" | "git_checkpoint" | "cloud"
    CreatedAt  time.Time `json:"created_at"`
    SizeBytes  int64     `json:"size_bytes"`
    Path       string    `json:"path,omitempty"`
    CloudURL   string    `json:"cloud_url,omitempty"`
    CommitHash string    `json:"commit_hash,omitempty"`
    Trigger    string    `json:"trigger"`        // "auto", "manual", "pre_ai", "pre_delete"
    Note       string    `json:"note,omitempty"`
}
```

### 4.4 Çalışma Zamanı Akışları — Detay

**Proje başlatma:**
1. `POST /api/projects/:id/start`
2. Handler → `runner.Start(project)`
3. Runner: environment'a göre komutu belirler (`npm start`, `flutter run`, `python manage.py runserver`, ...)
4. `os/exec.Cmd` ile başlatır, stdout/stderr'ı bir log dosyasına yazar
5. PID'i tutar, status'u `starting` yapar
6. Flutter projesi ise log'u izler, `Flutter run key commands` görünce status `running` olur
7. WebSocket `events` kanalından push: `{"type":"project.status","id":"x","status":"running","port":3000}`
8. Flutter UI otomatik güncellenir

**Dosya değişikliği izleme:**
1. Proje açıldığında `fsnotify` watcher başlar
2. Herhangi bir dosya değişirse → WebSocket `fs` kanalından push: `{"type":"fs.change","path":"lib/main.dart","kind":"modify"}`
3. Flutter tarafında dosya ağacı otomatik yenilenir, açık editör varsa "dosya disk'te değişti, yeniden yükle?" banner'ı gösterir

**AI Sohbet Akışı:**
1. WebSocket'ten `{"type":"chat.input","sid":"abc","text":"..."}` gelir
2. `chat_handler.go` → `AIService.Chat(ctx, sid, text)`
3. Service bağlamı toplar: proje dizini, dahil edilen dosyalar, konuşma geçmişi
4. Anthropic API'ye stream request
5. Gelen event'ler WebSocket'e push edilir — her bir event tipi Bölüm 6'da
6. Tool call geldiğinde:
   - Otomatik izin kuralına girerse (ayarlardan) → hemen çalıştır
   - Aksi halde → Flutter'a `chat.permission_request` push → kullanıcı onayı bekle
7. Stream bitince → `chat.done` push, konuşma SQLite'a kaydedilir

---

## 5. API Sözleşmesi — Tüm Endpoint'ler

Tüm HTTP endpoint'leri `http://localhost:8080` altında, JSON request/response kullanır, Turkish character desteği tam UTF-8'dir. WebSocket endpoint'leri ayrıca Bölüm 6'da anlatılır.

### 5.1 Sistem

| Metod | Yol | Request | Response | Açıklama |
|---|---|---|---|---|
| GET | `/api/health` | — | `{ok, version, uptime_sec, projects_running, ai_ready}` | Hızlı ping |
| GET | `/api/system/info` | — | `{os, arch, cpu, ram_mb, disk_free_gb, android_sdk, termux_version, go_version, git_version, node_version, python_version, cloudflared_version}` | Sistem bilgisi |
| GET | `/api/system/stats` | — | `{cpu_percent, ram_used_mb, ram_total_mb, battery_percent, battery_charging, temperature_c, uptime_sec}` | Canlı sistem istatistikleri |
| POST | `/api/system/shutdown` | — | `{ok}` | Sunucuyu güvenli kapatır |

### 5.2 Kurulum Sihirbazı

| Metod | Yol | Request | Response | Açıklama |
|---|---|---|---|---|
| GET | `/api/setup/status` | — | `{completed, step, missing: [], cli_status}` | Kurulum durumu |
| GET | `/api/setup/cli/detect` | — | `{claude: {installed, version, path, logged_in}, gemini: {installed, version, path, logged_in}}` | CLI tespiti |
| POST | `/api/setup/cli/install` | `{provider: "claude"\|"gemini"}` | `{task_id}` | CLI kur (stream log WS'den gelir) |
| POST | `/api/setup/cli/login` | `{provider}` | `{task_id, auth_url?}` | CLI login başlat (auth URL stream'den gelir) |
| POST | `/api/setup/cli/logout` | `{provider}` | `{ok}` | Hesaptan çık |
| POST | `/api/setup/cli/test` | `{provider}` | `{ok, models: [], error?}` | Login'i ping et |
| POST | `/api/setup/preferences` | `{theme, language, projects_dir?, default_provider?, default_model?, auto_backup?, ...}` | `{ok}` | İlk tercihler |
| POST | `/api/setup/complete` | — | `{ok}` | Sihirbazı tamamla |
| POST | `/api/setup/reset` | — | `{ok}` | Sıfırla (tekrar sihirbaz) |

### 5.3 Projeler

| Metod | Yol | Request | Response | Açıklama |
|---|---|---|---|---|
| GET | `/api/projects` | — | `{projects: [Project], total}` | Tümü |
| GET | `/api/projects/:id` | — | `Project` | Tek |
| POST | `/api/projects` | `{name, env?, source, git_repo?, branch?, port?, entry_cmd?, group?}` | `Project` | Oluştur |
| PATCH | `/api/projects/:id` | `{name?, env?, port?, entry_cmd?, group?, favorite?}` | `Project` | Güncelle |
| DELETE | `/api/projects/:id` | `?keep_files=0\|1` | `{ok}` | Sil (dosyalar opsiyonel) |
| POST | `/api/projects/:id/start` | — | `{ok, port, log_url}` | Dev server başlat |
| POST | `/api/projects/:id/stop` | — | `{ok}` | Durdur |
| POST | `/api/projects/:id/restart` | — | `{ok}` | Yeniden başlat |
| POST | `/api/projects/:id/refresh` | — | `{ok, updated_files: []}` | Git pull + bağımlılık tazele |
| GET | `/api/projects/:id/logs` | `?lines=400&src=server\|tunnel` | `{logs: string}` | Son N satır log |
| POST | `/api/projects/:id/input` | `{text}` | `{ok}` | Çalışan process'in stdin'ine yaz |
| GET | `/api/projects/:id/export` | — | binary zip | Proje ZIP indir |
| POST | `/api/projects/import/zip` | multipart | `Project` | ZIP'ten içe aktar |
| POST | `/api/projects/import/clone` | `{url, branch?, name?}` | `Project` | Git clone ile içe aktar |
| GET | `/api/projects/:id/qr` | — | `{svg, png_base64}` | Tunnel QR kod |

### 5.4 Dosyalar

| Metod | Yol | Request | Response | Açıklama |
|---|---|---|---|---|
| GET | `/api/projects/:id/files` | `?path=/&depth=3` | `{tree: FileNode}` | Ağaç |
| GET | `/api/projects/:id/file` | `?path=lib/main.dart` | `{content, size, language, encoding, mtime}` | Oku (max 5MB) |
| PUT | `/api/projects/:id/file` | `{path, content, create_dirs?}` | `{ok, size}` | Yaz |
| POST | `/api/projects/:id/file/new` | `{path, is_dir, template?}` | `{ok}` | Oluştur |
| DELETE | `/api/projects/:id/file` | `{path}` | `{ok}` | Sil |
| POST | `/api/projects/:id/file/rename` | `{old_path, new_path}` | `{ok}` | Taşı/yeniden adlandır |
| POST | `/api/projects/:id/file/duplicate` | `{path}` | `{ok, new_path}` | Kopyala |
| GET | `/api/projects/:id/search` | `?q=...&case=0\|1&regex=0\|1&glob=` | `{results: [SearchHit]}` | Grep |
| POST | `/api/projects/:id/replace` | `{q, replacement, case?, regex?, glob?, dry_run?}` | `{changes: []}` | Toplu değiştir |

### 5.5 Git

| Metod | Yol | Request | Response | Açıklama |
|---|---|---|---|---|
| GET | `/api/projects/:id/git/status` | — | `{branch, ahead, behind, staged: [], unstaged: [], untracked: []}` | Durum |
| GET | `/api/projects/:id/git/log` | `?limit=50` | `{commits: []}` | Tarihçe |
| GET | `/api/projects/:id/git/diff` | `?ref1=&ref2=&path?` | `{diffs: [{path, hunks}]}` | Diff |
| POST | `/api/projects/:id/git/commit` | `{message, files?, all?}` | `{ok, hash}` | Commit |
| POST | `/api/projects/:id/git/checkout` | `{ref, create?}` | `{ok, branch}` | Branch geç/oluştur |
| POST | `/api/projects/:id/git/pull` | — | `{ok, updated_files: []}` | Pull |
| POST | `/api/projects/:id/git/push` | `{remote?, branch?}` | `{ok}` | Push |
| POST | `/api/projects/:id/git/stash` | `{message?}` | `{ok}` | Stash |
| POST | `/api/projects/:id/git/restore` | `{ref, paths?}` | `{ok}` | Geri al |
| GET | `/api/git/branches` | `?repo=<url>` | `{branches, default}` | Uzak branch listesi |

### 5.6 Yedekleme

| Metod | Yol | Request | Response | Açıklama |
|---|---|---|---|---|
| GET | `/api/backups` | `?project_id=` | `{backups: []}` | Liste |
| POST | `/api/backups` | `{project_id, type, note?}` | `Backup` | Manuel yedek al |
| GET | `/api/backups/:id` | — | `Backup` | Detay |
| GET | `/api/backups/:id/download` | — | binary | Yedek indir |
| POST | `/api/backups/:id/restore` | `{overwrite_current?, create_new_project?}` | `{ok, project_id}` | Geri yükle |
| DELETE | `/api/backups/:id` | — | `{ok}` | Sil |
| POST | `/api/backups/settings` | `{auto_enabled, interval_minutes, retention_count, git_enabled, cloud_*}` | `{ok}` | Yedek ayarları |
| POST | `/api/backups/cloud/connect` | `{provider, oauth_token}` | `{ok}` | Cloud bağla |
| POST | `/api/backups/cloud/disconnect` | — | `{ok}` | Cloud çöz |

### 5.7 AI (Sohbet / Konuşma)

| Metod | Yol | Request | Response | Açıklama |
|---|---|---|---|---|
| GET | `/api/conversations` | `?project_id=&provider=&limit=50` | `{conversations: [ConvSummary]}` | Liste |
| GET | `/api/conversations/:id` | — | `{conversation: Conversation, messages: [Message]}` | Tam |
| POST | `/api/conversations` | `{project_id, provider, model?, title?, system_prompt?}` | `Conversation` | Yeni sohbet |
| PATCH | `/api/conversations/:id` | `{title?, archive?}` | `{ok}` | Güncelle |
| DELETE | `/api/conversations/:id` | — | `{ok}` | Sil |
| POST | `/api/conversations/:id/branch` | `{from_message_id}` | `Conversation` | Bir noktadan fork |
| POST | `/api/conversations/:id/summarize` | — | `{summary, new_conversation_id}` | Özetle + yeni sohbete taşı |
| GET | `/api/conversations/:id/export/markdown` | — | `{markdown}` | Dışa aktar |
| POST | `/api/conversations/:id/fork-to` | `{target_provider}` | `Conversation` | Claude ↔ Gemini köprü |

**Not:** Mesaj gönderme ve stream **WebSocket üzerinden** yapılır, REST değildir. Bkz. Bölüm 6.

### 5.8 AI — Tool İzinleri ve Sistem

| Metod | Yol | Request | Response | Açıklama |
|---|---|---|---|---|
| GET | `/api/ai/tools` | — | `{tools: [{name, description, schema}]}` | Kayıtlı tool'lar |
| GET | `/api/ai/permissions` | — | `{rules: []}` | İzin kuralları |
| POST | `/api/ai/permissions` | `{tool_name, scope, policy}` | `{ok}` | Kural ekle/güncelle |
| DELETE | `/api/ai/permissions/:id` | — | `{ok}` | Kural sil |
| POST | `/api/ai/permissions/reset` | — | `{ok}` | Tümünü sıfırla |
| GET | `/api/ai/usage` | `?project_id=&from=&to=` | `{daily: [{date, tokens, cost}], total}` | Maliyet izleme |
| GET | `/api/ai/context-files/:conversation_id` | — | `{files: [{path, included}]}` | Sohbete eklenen dosyalar |
| POST | `/api/ai/context-files/:conversation_id` | `{path, included}` | `{ok}` | Dosya ekle/çıkar |
| GET | `/api/ai/prompts` | — | `{prompts: []}` | Prompt kütüphanesi |
| POST | `/api/ai/prompts` | `{title, content, tags?}` | `Prompt` | Kütüphaneye ekle |
| DELETE | `/api/ai/prompts/:id` | — | `{ok}` | Sil |

### 5.9 Terminal

| Metod | Yol | Request | Response | Açıklama |
|---|---|---|---|---|
| GET | `/api/terminals` | — | `{terminals: [{id, cwd, created_at, alive}]}` | Açık PTY'ler |
| POST | `/api/terminals` | `{cwd?, cols?, rows?, shell?}` | `{id, cwd}` | Yeni PTY |
| DELETE | `/api/terminals/:id` | — | `{ok}` | Kapat |
| POST | `/api/terminals/:id/resize` | `{cols, rows}` | `{ok}` | Yeniden boyutlandır |

**Not:** Terminal I/O **WebSocket üzerinden** akar.

### 5.10 Tunnel

| Metod | Yol | Request | Response | Açıklama |
|---|---|---|---|---|
| POST | `/api/projects/:id/tunnel/start` | `{provider?}` | `{url, provider}` | Tunnel aç |
| POST | `/api/projects/:id/tunnel/stop` | — | `{ok}` | Kapat |
| GET | `/api/projects/:id/tunnel` | — | `{active, url?, provider?, started_at?}` | Durum |

### 5.11 Ayarlar

| Metod | Yol | Request | Response | Açıklama |
|---|---|---|---|---|
| GET | `/api/settings` | — | `Settings` | Tüm ayarlar |
| PATCH | `/api/settings` | partial | `Settings` | Güncelle |
| POST | `/api/settings/theme` | `{accent, bg, surface, text, font_family, font_size}` | `{ok}` | Tema özel |
| POST | `/api/settings/shortcuts` | `{quick_actions: []}` | `{ok}` | Sohbet kısayolları |
| GET | `/api/settings/export` | — | yaml | Tüm ayarları dışa aktar |
| POST | `/api/settings/import` | yaml body | `{ok}` | İçe aktar |

### 5.12 Bildirimler

| Metod | Yol | Request | Response | Açıklama |
|---|---|---|---|---|
| GET | `/api/notifications` | `?unread=1` | `{notifications: []}` | Liste |
| POST | `/api/notifications/:id/read` | — | `{ok}` | Okundu |
| POST | `/api/notifications/read-all` | — | `{ok}` | Hepsini okundu |
| DELETE | `/api/notifications/:id` | — | `{ok}` | Sil |
| POST | `/api/notifications/settings` | `{rules: {...}}` | `{ok}` | Kural güncelle |

### 5.13 AI Yardımcı Aksiyonları (Sohbet dışı)

| Metod | Yol | Request | Response | Açıklama |
|---|---|---|---|---|
| POST | `/api/ai/analyze-error` | `{log_excerpt, file_path?, project_id}` | `{analysis, suggested_fix, files_to_inspect: []}` | Hata analizi |
| POST | `/api/ai/explain-code` | `{code, language?, context?}` | `{explanation}` | Kod açıkla |
| POST | `/api/ai/generate-commit-message` | `{project_id}` | `{message}` | Git diff'ten commit mesajı |
| POST | `/api/ai/review-diff` | `{project_id, ref1?, ref2?}` | `{issues: [], suggestions: []}` | Diff incele |
| POST | `/api/ai/suggest-project-setup` | `{project_id}` | `{steps: []}` | README'den kurulum öner |
| POST | `/api/ai/speech-to-text` | `{audio_base64, format}` | `{text}` | Proxy (Flutter native kullanacak ama backup olarak) |

---

## 6. WebSocket Protokolü — Mesaj Formatı

### 6.1 Bağlantı

Tek bir WebSocket endpoint'i: `ws://localhost:8080/ws`

İstemci bağlandıktan sonra kanallara abone olur. Bir bağlantıda birden çok kanala abone olunabilir.

### 6.2 Kanallar

| Kanal | Amaç |
|---|---|
| `chat` | AI sohbet mesajları ve stream |
| `terminal` | PTY I/O |
| `events` | Sistem olayları (proje başladı, hata, bildirim) |
| `fs` | Dosya değişim bildirimleri |
| `ai_events` | AI-spesifik: token kullanımı, maliyet güncellemesi |

### 6.3 Mesaj Genel Formatı

Tüm mesajlar JSON'dır:

```json
{
  "channel": "chat",
  "type": "chat.chunk",
  "id": "msg_abc123",
  "timestamp": 1729300000000,
  "payload": { ... }
}
```

- `channel`: aboneliğin adı
- `type`: olay tipi (kanal prefix'li, örn `chat.chunk`, `terminal.data`, `events.project_started`)
- `id`: benzersiz mesaj ID (mesaj kaybını tespit için)
- `timestamp`: UNIX millis
- `payload`: tipe özel veri

### 6.4 İstemci → Sunucu Mesajları

**Abone ol / çık:**
```json
{"type":"subscribe","channels":["chat","events","fs"]}
{"type":"unsubscribe","channels":["fs"]}
```

**Sohbet — Yeni mesaj gönder:**
```json
{
  "type":"chat.input",
  "payload": {
    "conversation_id":"conv_abc",
    "text":"Bu kodda hata var mı?",
    "context_files":["lib/main.dart","pubspec.yaml"],
    "images":[],
    "options": {"model":"claude-sonnet-4-5","max_tokens":8192,"extended_thinking":false}
  }
}
```

**Sohbet — Durdur:**
```json
{"type":"chat.abort","payload":{"conversation_id":"conv_abc"}}
```

**Sohbet — Tool izin cevabı:**
```json
{"type":"chat.tool_decision","payload":{"tool_use_id":"tu_xyz","decision":"allow","remember":"this_tool_always"}}
// decision: "allow" | "deny" | "allow_once" | "allow_always" | "deny_always"
// remember: "this_time_only" | "this_tool_always" | "this_project_always"
```

**Terminal — Açılan terminal'e bağlan:**
```json
{"type":"terminal.attach","payload":{"terminal_id":"term_123"}}
```

**Terminal — stdin yaz:**
```json
{"type":"terminal.input","payload":{"terminal_id":"term_123","data":"ls -la\n"}}
```

**Terminal — yeniden boyutlandır:**
```json
{"type":"terminal.resize","payload":{"terminal_id":"term_123","cols":80,"rows":24}}
```

**Ping/pong (keepalive):**
```json
{"type":"ping","payload":{"t":1729300000000}}
```

### 6.5 Sunucu → İstemci Mesajları

#### 6.5.1 Sohbet kanalı

**`chat.start`** — Yanıt üretimi başladı
```json
{"type":"chat.start","payload":{"conversation_id":"conv_abc","message_id":"msg_def","model":"claude-sonnet-4-5"}}
```

**`chat.thinking`** — Extended thinking delta (Claude)
```json
{"type":"chat.thinking","payload":{"message_id":"msg_def","delta":"..."}}
```

**`chat.text`** — Metin delta
```json
{"type":"chat.text","payload":{"message_id":"msg_def","delta":"Elbette, kodu inceliyorum..."}}
```

**`chat.tool_call_start`** — Tool çağrısı başlıyor
```json
{"type":"chat.tool_call_start","payload":{"message_id":"msg_def","tool_use_id":"tu_xyz","name":"read_file"}}
```

**`chat.tool_input_delta`** — Tool argüman delta (JSON biriktiriliyor)
```json
{"type":"chat.tool_input_delta","payload":{"tool_use_id":"tu_xyz","partial_json":"{\"path\":\"lib/"}}
```

**`chat.tool_call_end`** — Tool argümanı tamamlandı
```json
{"type":"chat.tool_call_end","payload":{"tool_use_id":"tu_xyz","name":"read_file","input":{"path":"lib/main.dart"}}}
```

**`chat.permission_request`** — Tool için izin isteniyor
```json
{
  "type":"chat.permission_request",
  "payload": {
    "tool_use_id":"tu_xyz",
    "tool_name":"write_file",
    "input":{"path":"lib/main.dart","content":"..."},
    "danger_level":"medium",
    "preview":{"type":"diff","old":"...","new":"..."}
  }
}
```

**`chat.tool_result`** — Tool sonucu
```json
{"type":"chat.tool_result","payload":{"tool_use_id":"tu_xyz","output":"...","is_error":false,"duration_ms":124}}
```

**`chat.done`** — Yanıt tamamlandı
```json
{
  "type":"chat.done",
  "payload": {
    "message_id":"msg_def",
    "stop_reason":"end_turn",
    "stats":{"input_tokens":1234,"output_tokens":567,"cache_tokens":890,"total_cost":0.0234,"duration_ms":3421}
  }
}
```

**`chat.error`** — Hata
```json
{"type":"chat.error","payload":{"message_id":"msg_def","error":"rate_limit","message":"..."}}
```

#### 6.5.2 Terminal kanalı

**`terminal.data`** — PTY çıktısı (binary-safe, base64)
```json
{"type":"terminal.data","payload":{"terminal_id":"term_123","data":"..."}}
```

Data düz UTF-8 string'dir. Binary gerekirse `"data_b64":"..."` alanı kullanılır.

**`terminal.exit`** — Terminal kapandı
```json
{"type":"terminal.exit","payload":{"terminal_id":"term_123","exit_code":0}}
```

#### 6.5.3 Events kanalı

**`events.project_status`** — Proje durumu değişti
```json
{"type":"events.project_status","payload":{"project_id":"x","status":"running","port":3000}}
```

**`events.project_log`** — Yeni log satırı (sadece abone olan proje için)
```json
{"type":"events.project_log","payload":{"project_id":"x","line":"...","stream":"stdout","timestamp":...}}
```

**`events.tunnel_ready`** — Tunnel URL hazır
```json
{"type":"events.tunnel_ready","payload":{"project_id":"x","url":"https://....trycloudflare.com"}}
```

**`events.backup_created`**, **`events.backup_failed`** — Yedekleme olayları

**`events.notification`** — Yeni bildirim (detay Bölüm 13'te)
```json
{
  "type":"events.notification",
  "payload": {
    "id":"notif_123",
    "category":"ai_response",
    "title":"Claude cevapladı",
    "body":"3 dosya değiştirildi",
    "importance":"normal",
    "actions":[{"id":"view","label":"Görüntüle"},{"id":"dismiss","label":"Kapat"}],
    "deep_link":"/chat/conv_abc"
  }
}
```

**`events.setup_required`** — Kurulum eksik
```json
{"type":"events.setup_required","payload":{"reason":"cli_not_logged_in","provider":"claude"}}
```

#### 6.5.4 FS kanalı

**`fs.change`** — Dosya değişti
```json
{"type":"fs.change","payload":{"project_id":"x","path":"lib/main.dart","kind":"modify","size":1234}}
// kind: "create" | "modify" | "delete" | "rename"
```

### 6.6 Güvenilirlik

- **Keepalive:** İstemci 30 saniyede bir `ping` gönderir, sunucu `pong` ile cevap verir. 60 saniye cevap yoksa istemci reconnect eder.
- **Reconnect:** Bağlantı kopunca Flutter `last_message_id` tutar. Yeniden bağlandığında `{"type":"resume","payload":{"from_id":"msg_xyz"}}` gönderir. Sunucu o ID'den sonraki mesajları tekrar yollar (3 dakika cache).
- **Backpressure:** Sunucu `chat.text` delta'larını 50ms'de bir flush eder (16ms'de değil), UI'ı boğmamak için.

---

## 7. Flutter Uygulaması — Mimari ve Dizin Yapısı

### 7.1 Dizin Yapısı

```
mobile/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── config/
│   │   │   ├── app_config.dart
│   │   │   └── build_info.dart
│   │   ├── constants/
│   │   │   ├── api_paths.dart
│   │   │   ├── ws_types.dart               # WebSocket message type sabitleri
│   │   │   ├── storage_keys.dart
│   │   │   └── default_prompts.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── color_schemes.dart
│   │   │   ├── typography.dart
│   │   │   ├── dynamic_theme.dart
│   │   │   └── component_styles.dart
│   │   ├── router/
│   │   │   ├── app_router.dart
│   │   │   └── route_paths.dart
│   │   ├── errors/
│   │   │   ├── app_exception.dart
│   │   │   ├── error_mapper.dart
│   │   │   └── error_reporter.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── ws_client.dart
│   │   │   ├── ws_channel.dart
│   │   │   ├── network_status.dart
│   │   │   └── interceptors/
│   │   │       ├── logging_interceptor.dart
│   │   │       ├── retry_interceptor.dart
│   │   │       └── auth_interceptor.dart
│   │   ├── storage/
│   │   │   ├── secure_storage.dart          # Yerel server token, session id
│   │   │   ├── prefs_storage.dart
│   │   │   └── cache_storage.dart
│   │   ├── native/
│   │   │   ├── termux_bridge.dart
│   │   │   ├── lifecycle_bridge.dart
│   │   │   ├── notification_bridge.dart
│   │   │   ├── speech_bridge.dart
│   │   │   ├── screenshot_bridge.dart
│   │   │   └── server_launcher.dart
│   │   ├── utils/
│   │   │   ├── formatters.dart
│   │   │   ├── file_icons.dart
│   │   │   ├── ansi_parser.dart
│   │   │   ├── debouncer.dart
│   │   │   ├── haptics.dart
│   │   │   ├── validators.dart
│   │   │   ├── clipboard.dart
│   │   │   └── env_colors.dart              # "flutter"=mavi, "python"=yeşil vs.
│   │   └── widgets/
│   │       ├── app_scaffold.dart
│   │       ├── shell_nav.dart
│   │       ├── empty_state.dart
│   │       ├── loading_skeleton.dart
│   │       ├── error_banner.dart
│   │       ├── confirmation_sheet.dart
│   │       ├── status_dot.dart
│   │       ├── bottom_sheet_container.dart
│   │       ├── swipe_action_tile.dart
│   │       ├── gradient_card.dart
│   │       ├── animated_counter.dart
│   │       └── keyboard_aware_scrollview.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── project.dart
│   │   │   ├── file_node.dart
│   │   │   ├── log_entry.dart
│   │   │   ├── tunnel.dart
│   │   │   ├── conversation.dart
│   │   │   ├── message.dart
│   │   │   ├── content_block.dart
│   │   │   ├── tool_call.dart
│   │   │   ├── permission_request.dart
│   │   │   ├── context_file.dart
│   │   │   ├── prompt_entry.dart
│   │   │   ├── stats.dart
│   │   │   ├── terminal_session.dart
│   │   │   ├── backup.dart
│   │   │   ├── notification.dart
│   │   │   ├── system_info.dart
│   │   │   ├── settings.dart
│   │   │   ├── git_status.dart
│   │   │   ├── git_commit.dart
│   │   │   ├── diff.dart
│   │   │   └── usage_stats.dart
│   │   ├── repositories/
│   │   │   ├── projects_repository.dart
│   │   │   ├── files_repository.dart
│   │   │   ├── git_repository.dart
│   │   │   ├── backup_repository.dart
│   │   │   ├── chat_repository.dart
│   │   │   ├── terminal_repository.dart
│   │   │   ├── system_repository.dart
│   │   │   ├── settings_repository.dart
│   │   │   ├── notification_repository.dart
│   │   │   └── setup_repository.dart
│   │   └── usecases/
│   │       ├── start_project_usecase.dart
│   │       ├── create_checkpoint_usecase.dart
│   │       ├── send_chat_message_usecase.dart
│   │       └── ... (ihtiyaç duyulan her iş akışı)
│   ├── data/
│   │   ├── models/
│   │   │   └── *.dart                        # Her entity için DTO
│   │   ├── mappers/
│   │   │   └── *.dart
│   │   └── repositories_impl/
│   │       └── *.dart
│   └── features/
│       ├── setup/
│       │   ├── presentation/
│       │   │   ├── setup_wizard_page.dart
│       │   │   ├── pages/
│       │   │   │   ├── welcome_page.dart
│       │   │   │   ├── termux_check_page.dart
│       │   │   │   ├── permissions_page.dart
│       │   │   │   ├── ai_keys_page.dart
│       │   │   │   ├── preferences_page.dart
│       │   │   │   ├── first_project_page.dart
│       │   │   │   └── done_page.dart
│       │   │   └── providers/
│       │   │       ├── setup_controller.dart
│       │   │       └── step_provider.dart
│       │   └── widgets/
│       │       ├── wizard_shell.dart
│       │       ├── step_indicator.dart
│       │       ├── key_input_field.dart
│       │       ├── key_validation_badge.dart
│       │       ├── permission_request_card.dart
│       │       └── termux_status_card.dart
│       ├── boot/
│       │   ├── presentation/
│       │   │   ├── boot_page.dart
│       │   │   └── boot_controller.dart
│       │   └── widgets/
│       │       ├── server_health_indicator.dart
│       │       ├── retry_panel.dart
│       │       └── termux_missing_card.dart
│       ├── home/
│       │   ├── presentation/
│       │   │   ├── home_page.dart              # Ana dashboard
│       │   │   └── providers/
│       │   │       └── home_dashboard_provider.dart
│       │   └── widgets/
│       │       ├── active_projects_carousel.dart
│       │       ├── quick_actions_grid.dart
│       │       ├── recent_conversations_list.dart
│       │       ├── system_stats_card.dart
│       │       └── notification_feed_card.dart
│       ├── projects/
│       │   ├── presentation/
│       │   │   ├── projects_list_page.dart
│       │   │   ├── project_detail_page.dart
│       │   │   ├── project_create_page.dart
│       │   │   ├── project_logs_page.dart
│       │   │   ├── project_git_page.dart
│       │   │   └── providers/
│       │   │       ├── projects_provider.dart
│       │   │       ├── project_detail_provider.dart
│       │   │       ├── project_action_provider.dart
│       │   │       ├── logs_provider.dart
│       │   │       └── git_provider.dart
│       │   └── widgets/
│       │       ├── project_card.dart
│       │       ├── project_card_compact.dart
│       │       ├── env_badge.dart
│       │       ├── status_chip.dart
│       │       ├── tunnel_card.dart
│       │       ├── start_stop_button.dart
│       │       ├── log_viewer.dart
│       │       ├── log_line.dart
│       │       ├── filter_chip_bar.dart
│       │       ├── create_project_sheet.dart
│       │       ├── git_status_bar.dart
│       │       ├── git_commit_list.dart
│       │       └── diff_viewer.dart
│       ├── files/
│       │   ├── presentation/
│       │   │   ├── file_tree_page.dart
│       │   │   ├── editor_page.dart
│       │   │   ├── file_search_page.dart
│       │   │   └── providers/
│       │   │       ├── file_tree_provider.dart
│       │   │       ├── file_content_provider.dart
│       │   │       ├── editor_controller_provider.dart
│       │   │       └── file_search_provider.dart
│       │   └── widgets/
│       │       ├── file_tree_node.dart
│       │       ├── file_search_bar.dart
│       │       ├── monaco_editor.dart
│       │       ├── editor_toolbar.dart
│       │       ├── editor_status_bar.dart
│       │       ├── file_context_menu.dart
│       │       ├── quick_open_palette.dart
│       │       └── replace_bar.dart
│       ├── terminal/
│       │   ├── presentation/
│       │   │   ├── terminal_page.dart
│       │   │   └── providers/
│       │   │       ├── terminal_sessions_provider.dart
│       │   │       ├── active_terminal_provider.dart
│       │   │       └── terminal_stream_provider.dart
│       │   └── widgets/
│       │       ├── xterm_view.dart
│       │       ├── term_tab_bar.dart
│       │       ├── virtual_keyboard.dart
│       │       ├── ctrl_key_row.dart
│       │       ├── arrow_key_pad.dart
│       │       └── terminal_toolbar.dart
│       ├── chat/
│       │   ├── presentation/
│       │   │   ├── chat_home_page.dart
│       │   │   ├── chat_session_page.dart
│       │   │   ├── conversation_list_page.dart
│       │   │   ├── prompt_library_page.dart
│       │   │   ├── usage_dashboard_page.dart
│       │   │   └── providers/
│       │   │       ├── chat_stream_provider.dart
│       │   │       ├── chat_messages_provider.dart
│       │   │       ├── chat_input_provider.dart
│       │   │       ├── permission_queue_provider.dart
│       │   │       ├── context_files_provider.dart
│       │   │       ├── prompt_library_provider.dart
│       │   │       └── usage_provider.dart
│       │   └── widgets/
│       │       ├── message_bubble.dart
│       │       ├── user_message.dart
│       │       ├── assistant_message.dart
│       │       ├── thinking_bar.dart
│       │       ├── thinking_preview.dart
│       │       ├── tool_call_card.dart
│       │       ├── tool_result_card.dart
│       │       ├── tool_diff_card.dart
│       │       ├── permission_dialog.dart
│       │       ├── permission_rule_chip.dart
│       │       ├── stats_footer.dart
│       │       ├── quick_actions_bar.dart
│       │       ├── slash_command_menu.dart
│       │       ├── chat_input_bar.dart
│       │       ├── attached_files_panel.dart
│       │       ├── context_file_chip.dart
│       │       ├── voice_input_button.dart
│       │       ├── screenshot_attach_button.dart
│       │       ├── code_block_actions.dart
│       │       ├── comparison_panel.dart       # Hibrit AI yan yana
│       │       ├── prompt_library_sheet.dart
│       │       └── cost_indicator.dart
│       ├── backup/
│       │   ├── presentation/
│       │   │   ├── backup_list_page.dart
│       │   │   ├── backup_detail_page.dart
│       │   │   └── providers/
│       │   │       └── backups_provider.dart
│       │   └── widgets/
│       │       ├── backup_card.dart
│       │       ├── backup_timeline.dart
│       │       ├── cloud_connect_sheet.dart
│       │       └── restore_confirmation_sheet.dart
│       ├── notifications/
│       │   ├── presentation/
│       │   │   ├── notifications_page.dart
│       │   │   └── providers/
│       │   │       └── notifications_provider.dart
│       │   └── widgets/
│       │       ├── notification_item.dart
│       │       ├── notification_category_header.dart
│       │       └── notification_action_button.dart
│       └── settings/
│           ├── presentation/
│           │   ├── settings_page.dart
│           │   ├── appearance_settings_page.dart
│           │   ├── editor_settings_page.dart
│           │   ├── terminal_settings_page.dart
│           │   ├── chat_settings_page.dart
│           │   ├── backup_settings_page.dart
│           │   ├── notification_settings_page.dart
│           │   ├── ai_settings_page.dart
│           │   ├── server_settings_page.dart
│           │   ├── advanced_settings_page.dart
│           │   ├── about_page.dart
│           │   └── providers/
│           │       └── settings_provider.dart
│           └── widgets/
│               ├── setting_tile.dart
│               ├── section_header.dart
│               ├── color_picker_tile.dart
│               ├── slider_tile.dart
│               ├── cli_login_tile.dart       # CLI durumu + login/logout/test butonları
│               └── test_connection_button.dart
├── assets/
│   ├── monaco/
│   │   ├── index.html
│   │   ├── editor.worker.js
│   │   ├── loader.js
│   │   └── vs/...
│   ├── fonts/
│   │   ├── Inter-*.ttf
│   │   └── JetBrainsMono-*.ttf
│   ├── icons/
│   │   └── *.svg
│   ├── lottie/
│   │   ├── splash.json
│   │   ├── empty_state.json
│   │   └── success.json
│   └── translations/
│       └── tr.json                            # İleride i18n için hazır
├── test/
│   ├── ws_protocol_test.dart
│   ├── api_mapper_test.dart
│   ├── permission_logic_test.dart
│   ├── backup_retention_test.dart
│   └── env_detector_test.dart
└── android/
    └── ... (bkz. Bölüm 8)
```

### 7.2 State Yönetimi Stratejisi

**Riverpod 2 + code-gen** kullanılır. Temel kural:

- **AsyncNotifier** (read + write): veri yükleme + mutation içeren durumlar
- **Notifier** (senkron): yerel UI state
- **Provider** (readonly): hesaplanmış değerler
- **StreamProvider**: WebSocket akışları

Tüm provider'lar `@riverpod` annotation'ı ile yazılır, `build_runner` `.g.dart` üretir (kullanıcı bunu çalıştırır).

### 7.3 Navigasyon

`go_router` kullanılır, nested routes:

```
/setup                          # İlk açılış sihirbazı
/boot                           # Server başlatma ekranı
/                               # Ana dashboard (home)
  /projects                     # Proje listesi
  /projects/new                 # Yeni proje
  /projects/:id                 # Proje detay
  /projects/:id/logs            # Loglar
  /projects/:id/git             # Git paneli
  /files                        # Dosya ağacı (proje seç)
  /files/:projectId             # Seçili projenin ağacı
  /files/:projectId/edit        # Editör (query: path)
  /terminal                     # Terminal
  /chat                         # AI ana ekran
  /chat/conversations           # Sohbet geçmişi
  /chat/prompts                 # Prompt kütüphanesi
  /chat/usage                   # Maliyet dashboard
  /chat/:conversationId         # Belirli sohbet
  /backups                      # Yedek listesi
  /backups/:id                  # Yedek detay
  /notifications                # Bildirim merkezi
  /settings                     # Ayarlar ana
  /settings/appearance
  /settings/editor
  /settings/terminal
  /settings/chat
  /settings/backup
  /settings/notifications
  /settings/ai
  /settings/server
  /settings/advanced
  /settings/about
```

Bottom navigation (AppShell):
- **Ana** (Home dashboard)
- **Projeler**
- **Dosyalar**
- **AI**
- **Terminal**

Ayarlar, Bildirimler, Yedekler üst sağ köşedeki profil/menü ikonundan ulaşılır (yer kazanmak için). Bu kararın gerekçesi: telefonda alt çubukta 5 ikonluk üst sınır var, en çok kullanılanları oraya koyduk. Ayarlar/Yedekler/Bildirimler görece daha az girilir.

### 7.5 Tema Sistemi

- **Material 3** tabanlı
- Dark-first, ama AMOLED (sade siyah) ve System (cihaz teması) seçenekleri var
- Accent: varsayılan `#5468ff`, kullanıcı color picker ile değiştirebilir
- `/api/settings/theme` dönen değerlere göre `ThemeData` dinamik oluşur
- Font: Inter (UI) + JetBrains Mono (kod ve terminal)

### 7.6 Global Floating Action Button (FAB) — "Komuta Merkezi"

Uygulamanın **her ekranında** (setup ve boot hariç) sağ altta yer alan sürüklenebilir bir FAB bulunur. Browser APK'sındaki FAB davranışı birebir uygulanır, ama menü içeriği tamamen Harun Vibe Coding'e özelleştirilmiştir.

#### 7.6.1 FAB Davranışı

- **Konum:** Varsayılan sağ alt, dp(64) sağdan, dp(80) alttan
- **Boyut:** 48x48 dp, yuvarlak
- **Varsayılan görünüm:** 4 saniye etkileşim olmazsa `alpha 0.25`'e fade out (2000ms animasyon)
- **Dokununca:** Tam opaklığa döner, menü açılır
- **Sürüklenebilir:** Uzun basılıp sürüklenebilir, bırakıldığı yere snap eder
- **Ekran kenarlarında kalmaya çalışır:** Sürükleme sonrası en yakın kenara snap (sol veya sağ)
- **İkon:** Harun Vibe Coding logosu veya ⚡ (şimşek)
- **Renk:** Accent (`#5468ff`) dolu daire, beyaz ikon
- **Haptic feedback:** Tap, sürükleme başlangıcı ve snap'te

#### 7.6.2 FAB Menüsü (Tap ile)

Menü açıldığında:
- Arka plan `0x88000000` semi-transparent overlay (tap edilirse kapanır)
- Menü card: 260dp genişlik, koyu gradient arka plan, 20dp kavisli köşe, 1dp border, 24dp elevation
- Animasyon: 180ms scale (0.95 → 1) + fade-in (0 → 1), pivot FAB konumu
- Kapatma: 120ms fade-out
- Menü FAB'ın üstünde açılır (FAB alttaysa yukarı), kenar taşarsa FAB'ın altına düşer

Menü **4 kategori** içerir, her kategorinin başlığı altında 4 yuvarlak buton (52dp, yatay row):

**Kategori 1 — "Hızlı Aç" (Nav)**
- 🏠 **Ana** (accent) → `/`
- 📁 **Projeler** (mavi `#3B82F6`) → `/projects`
- 🤖 **AI** (mor `#8B5CF6`) → `/chat`
- 🖥 **Terminal** (yeşil `#22C55E`) → `/terminal`

**Kategori 2 — "Eylemler"**
- ➕ **Yeni Proje** (yeşil `#22C55E`) → proje oluştur sheet
- 💬 **Yeni Sohbet** (mor) → yeni AI sohbet
- 🔗 **Tunnel Paylaş** (pembe `#EC4899`) → aktif tunnel URL varsa share, yoksa gri
- 💾 **Yedek Al** (turuncu `#F59E0B`) → aktif projeye manuel yedek

**Kategori 3 — "Durum" (Toggle'lar)**
- 🌙 **Koyu Tema** toggle
- 🔕 **Sessiz** toggle (bildirimleri kapat)
- ⚡ **Dev Server** toggle (aktif proje varsa başlat/durdur)
- 🔴 **Acil Dur** (kırmızı `#EF4444`) → tüm çalışan projeleri durdur

**Kategori 4 — "Sistem" (Bilgi + aksiyonlar)**
- 📊 **Durum** (mavi) → sistem stats panelı aç (CPU/RAM/Pil bottom sheet)
- 🔄 **Yeniden Bağlan** (sarı) → WebSocket reconnect
- 🔍 **Global Ara** (cyan) → bottom sheet: proje/dosya/sohbet içinde ara
- ⚙ **Ayarlar** (gri) → `/settings`

**Alt bilgi çubuğu (menünün altı):**
- Sol: server status dot + "Sunucu çalışıyor" / "Bağlanılıyor"
- Orta: aktif proje sayısı rozeti
- Sağ: bekleyen bildirim sayısı (tap → /notifications)

#### 7.6.3 FAB'ın Bağlamsal Davranışı

Bulunduğu ekrana göre bazı butonlar değişir veya vurgulanır:

- **Sohbet ekranında:** "Sessiz" butonu yerine "Mikrofon" hızlı aksiyonu, "Dev Server Toggle" yerine "Son Çıktıyı Paylaş"
- **Editör ekranında:** "Yeni Proje" yerine "Kaydet", "Tunnel Paylaş" yerine "AI'a Sor"
- **Terminal ekranında:** "Yeni Proje" yerine "Yeni Tab", "Acil Dur" aynı ama "Tüm Terminalleri Kapat" anlamına gelir
- **Proje detay ekranında:** "Dev Server Toggle" o projeye özel hale gelir

Vibe coder bu bağlamsal varyasyonları için her feature'da FAB override callback'i sağlar (`FabContextProvider.overrideActions(List<FabAction>)`).

#### 7.6.4 FAB Widget Yapısı

```
mobile/lib/core/widgets/global_fab/
├── global_fab.dart                # Overlay widget, tüm ekranlarda Stack'ın en üstü
├── fab_controller.dart            # State (open/closed), animasyon
├── fab_menu_overlay.dart          # Menü container, tap outside to close
├── fab_menu_panel.dart            # 4 kategori, scrollable if needed
├── fab_menu_button.dart           # Her yuvarlak buton (icon + label)
├── fab_menu_toggle.dart           # Toggle variantı
├── fab_section_header.dart        # "Hızlı Aç" gibi başlıklar
├── fab_status_footer.dart         # Alt bilgi çubuğu
├── fab_position_manager.dart      # Sürükle-bırak + snap + fade
└── fab_context_provider.dart      # Ekran-bazlı override callback'i
```

#### 7.6.5 Neden FAB? (Karar Gerekçesi)

- Telefon tek elle kullanılır — bottom nav'da 5 sekme sınırı, daha fazla özelliğe direkt erişim gerekir
- FAB her ekrandan hızlı eylem sağlar (yeni sohbet, yeni proje, tunnel paylaş, sistem stats)
- Browser APK'sındaki FAB kullanıcı için alışkın olduğu bir pattern
- Fade-out davranışı içerikle çelişmeden görünür kalır
- Global erişim + bağlamsal varyasyon = hem tutarlı hem güçlü

---

## 8. Android Native — Termux Köprüsü ve Bildirim

### 8.1 AndroidManifest.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.harun.vibecoding">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.CAMERA" />

    <!-- KRİTİK: Termux ile intent iletişimi -->
    <uses-permission android:name="com.termux.permission.RUN_COMMAND" />

    <queries>
        <package android:name="com.termux" />
    </queries>

    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.microphone" android:required="false" />

    <application
        android:label="Harun Vibe Coding"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:theme="@style/LaunchTheme"
        android:usesCleartextTraffic="true"
        android:networkSecurityConfig="@xml/network_security_config"
        android:hardwareAccelerated="true">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:windowSoftInputMode="adjustResize">
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service
            android:name=".ServerLifecycleService"
            android:enabled="true"
            android:exported="false"
            android:foregroundServiceType="dataSync" />

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### 8.2 network_security_config.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">127.0.0.1</domain>
        <domain includeSubdomains="true">10.0.0.0/8</domain>
        <domain includeSubdomains="true">192.168.0.0/16</domain>
    </domain-config>
</network-security-config>
```

### 8.3 TermuxBridge.kt — Sözleşme

**MethodChannel adı:** `com.harun.vibecoding/termux`

**Metodlar (Flutter → Native):**

| Metod | Argümanlar | Dönüş | Açıklama |
|---|---|---|---|
| `isInstalled` | — | `Boolean` | Termux kurulu mu |
| `isAllowExternalAppsSet` | — | `Boolean` | `allow-external-apps=true` ayarı |
| `runScript` | `{workdir, scriptPath, background}` | `Map` | RunCommandService ile script çalıştır |
| `openTermux` | — | `null` | Termux ana ekranını aç |
| `openPlayStore` | — | `null` | Termux'u F-Droid/Play Store'da aç |

**KRİTİK intent extras — bunlar Termux'un beklediği tam string'lerdir:**

- `com.termux.RUN_COMMAND_PATH` (String) — çalıştırılacak binary
- `com.termux.RUN_COMMAND_ARGUMENTS` (String[]) — argümanlar
- `com.termux.RUN_COMMAND_WORKDIR` (String) — çalışma dizini
- `com.termux.RUN_COMMAND_BACKGROUND` (Boolean) — arka plan mı
- `com.termux.RUN_COMMAND_SESSION_ACTION` (Integer) — `0` = yeni session açma

Intent action: `com.termux.RUN_COMMAND`
Service: `com.termux/com.termux.app.RunCommandService`

**Backend Go binary başlatma akışı:**
1. Flutter, `runScript({scriptPath:"/data/data/com.termux/files/home/.harun-vibe/start.sh", workdir:"~", background:true})` çağırır
2. `start.sh` içeriği:
   ```bash
   #!/data/data/com.termux/files/usr/bin/bash
   export HOME=/data/data/com.termux/files/home
   cd "$HOME/.harun-vibe"
   exec ./harun-vibe-server --config config.yaml
   ```
3. Go binary ayaklanır, port 8080'i dinler
4. Flutter 400ms timeout ile `/api/health` poll eder, yeşil ışık alınca UI'a geçer

### 8.4 ServerLifecycleService.kt — Sözleşme

**MethodChannel adı:** `com.harun.vibecoding/service`

| Metod | Argümanlar | Açıklama |
|---|---|---|
| `startForeground` | `{title, text, icon?}` | Foreground service başlat |
| `stopForeground` | — | Service durdur |
| `updateForeground` | `{title, text, actions?}` | Bildirimi güncelle |
| `postNotification` | `{id, title, body, category, actions?, deep_link?, sound?, vibrate?}` | Discrete bildirim |
| `cancelNotification` | `{id}` | Bildirimi iptal |
| `requestBatteryExempt` | — | Battery optimization exemption iste |

**Bildirim kanalları (oluşturulacak):**

| Kanal ID | İsim | Önem | Sound | Vibrate |
|---|---|---|---|---|
| `hvc_service` | Dev Manager Servisi | LOW | — | — |
| `hvc_ai_response` | AI Cevapları | DEFAULT | Yes | Light |
| `hvc_ai_permission` | AI İzin İstekleri | HIGH | Yes | Heavy |
| `hvc_server_error` | Sunucu Hataları | HIGH | Yes | Heavy |
| `hvc_tunnel` | Tunnel Durumu | DEFAULT | Yes | Light |
| `hvc_backup` | Yedekleme | LOW | — | — |
| `hvc_system` | Sistem Uyarıları | DEFAULT | — | Light |

### 8.5 SpeechBridge.kt — Sözleşme

**MethodChannel adı:** `com.harun.vibecoding/speech`

| Metod | Açıklama |
|---|---|
| `isAvailable` | Android SpeechRecognizer var mı |
| `start` | `{locale:"tr-TR"}` — dinlemeye başla |
| `stop` | Durdur |
| `cancel` | İptal |

**EventChannel:** `com.harun.vibecoding/speech_events` — partial result ve final result push'lar.

### 8.6 ScreenshotBridge.kt — Sözleşme

**MethodChannel adı:** `com.harun.vibecoding/screenshot`

| Metod | Argümanlar | Dönüş |
|---|---|---|
| `captureScreen` | — | `String` (base64 PNG) |
| `captureWindow` | — | `String` (uygulama içi ekran görüntüsü, izin gerekmez) |
| `pickFromGallery` | — | `String` (base64) |
| `pickFromCamera` | — | `String` (base64) |

---

## 9. İlk Açılış Kurulum Sihirbazı

### 9.1 Tetikleme

Uygulama her açıldığında `/api/setup/status` çağrılır. `completed: false` dönerse `/setup` route'una yönlendirme yapılır. `completed: true` → `/boot` → `/` (Ana).

### 9.2 Adımlar

7 adımlı bir akış. Her adımda "Geri" ve "İleri" butonları, üstte step indicator (7 nokta, aktif olan dolu).

#### Adım 1 — Hoş Geldin

- Büyük logo, Lottie animasyon (açılış)
- "Harun Vibe Coding'e hoş geldiniz"
- Alt metin: "Telefonunuzda tam bir AI-destekli mobil IDE. Hazırlık 2 dakika sürer."
- Büyük "Başlayalım" butonu
- Alt sağ: "Sihirbazı atla" (gelişmiş kullanıcı için, her şey manuel)

#### Adım 2 — Termux Kontrolü

- `TermuxBridge.isInstalled()` çağrılır
- Kurulu değilse:
  - Büyük kırmızı uyarı kartı: "Termux kurulu değil"
  - "Termux, uygulamanın çekirdeğini çalıştıran ücretsiz bir terminaldir."
  - Üç buton: "F-Droid'de Aç" / "Play Store'da Aç" / "Nasıl kurarım?"
  - Kurulduktan sonra "Kontrol Et" butonu tekrar test eder
- Kurulu ama `allow-external-apps` ayarlı değilse:
  - Sarı uyarı kartı: "Termux yapılandırılmamış"
  - Numaralı talimat:
    1. Termux'u aç
    2. `nano ~/.termux/termux.properties` yaz
    3. `allow-external-apps = true` satırını ekle
    4. Ctrl+X → Y → Enter
    5. Termux'u tamamen kapatıp yeniden aç
  - "Tüm adımları yaptım" → tekrar test
- Her şey tamamsa:
  - Yeşil tik, "Termux hazır"
  - Otomatik Go binary indirilir/kopyalanır → `~/.harun-vibe/harun-vibe-server`
  - `start.sh` oluşturulur
  - "İleri" aktif olur

#### Adım 3 — İzinler

Runtime izinleri isteyen ekran. Her izin için açıklama + "İzin Ver" butonu.

- **Bildirimler** (`POST_NOTIFICATIONS`, Android 13+): "AI cevapları, sunucu hataları ve yedekleme bildirimleri için"
- **Mikrofon** (opsiyonel, `RECORD_AUDIO`): "Sohbete sesli mesaj göndermek için"
- **Galeri/Kamera** (opsiyonel): "Sohbete ekran görüntüsü veya resim eklemek için"
- **Pil optimizasyonu muafiyeti** (opsiyonel): "Arka planda da çalışmaya devam etmesi için"

Her izinde: yeşil tik / gri "atla" durumu gösterilir. Hepsi opsiyonel, sadece bildirim önerilir.

#### Adım 4 — AI Hesaplarına Giriş (CLI Login)

Başlık: **"AI Asistanını Bağla"**

Alt açıklama: *"Claude ve Gemini hesabınızla giriş yaparsınız, API anahtarı gerekmez. En az bir sağlayıcı yeterli. Kullanım kotanız kendi aboneliğinizden düşer."*

**İki büyük kart (her biri 3 durumlu):**

**Claude kartı:**

- Logo + başlık: *"Claude (Anthropic hesabınız)"*
- Alt metin: *"Claude Pro, Max veya Team aboneliği gerekir."*

Durum A — **CLI kurulu değil:**
- Kırmızı şerit: "Claude Code CLI kurulu değil"
- "Otomatik kur" butonu → backend `npm install -g @anthropic-ai/claude-code` komutunu Termux'ta arka planda çalıştırır
- Stream log kart içinde görünür (gerçek zamanlı output)
- Alternatif: "Nasıl manuel kurarım?" → detaylı talimat sheet'i

Durum B — **CLI kurulu, login olmamış:**
- Sarı şerit: "Giriş yapılmadı"
- **"Giriş yap"** büyük butonu → backend `claude login` komutunu PTY ile çalıştırır
- `claude login` bir URL basar (örn: `https://claude.ai/login/auth?code=...`) — backend bu URL'i yakalar
- Flutter uygulaması bir bottom sheet açar:
  - QR kod gösterir (URL'i kodlar)
  - Aynı zamanda "Tarayıcıda Aç" butonu (telefonun varsayılan tarayıcısına gönderir)
  - "URL'i kopyala" seçeneği
- Kullanıcı tarayıcıda giriş yapar, Claude hesabıyla onay verir
- `claude login` process'i success dönünce → yeşil tik
- Otomatik olarak `claude --version` ve mevcut model listesi kontrol edilir

Durum C — **Login tamam:**
- Yeşil tik + "Bağlı: sonnet-4-5, opus-4-7 modelleri kullanılabilir"
- "Çıkış yap" linki (nadiren ihtiyaç)
- "Test et" butonu → kısa bir ping mesajı gönderir

**Gemini kartı — aynı yapı:**
- CLI: `npm install -g @google/gemini-cli` veya homebrew alternatifi
- Login: `gemini auth login` komutu, Google OAuth akışı
- Browser-based login tetiklenir (tarayıcıda Google hesap onayı)

**Alt not:**
*"Her iki CLI da hesap oturum bilgilerini kendi yollarında saklar (`~/.claude/`, `~/.gemini/`). Harun Vibe Coding bu bilgilere dokunmaz, sadece CLI'ı çağırır. API anahtarınız bizde saklanmaz çünkü yok."*

En az bir CLI'da login başarılı olunca "İleri" aktif olur.

**Özel durum — offline:** Ağ yoksa "Ağ bağlantısı yok, CLI login için gerekli. İleride tekrar dene." uyarısı, "Bu adımı atla, sonra halledeceğim" seçeneği ile geçilebilir.

#### Adım 5 — Tercihler

- **Tema:** Dark / AMOLED Siyah / Sistem (radio)
- **Ana dil:** Türkçe (tek seçenek, ileride genişler)
- **Proje klasörü:** Varsayılan `~/HarunVibeCoding/projects` + "Değiştir" butonu
- **Varsayılan AI modeli:** Dropdown (Anthropic + Google arasından seç)
- **Otomatik yedekleme:** Switch (açık önerilir)
- **Yedek sıklığı:** 15 dk / 30 dk / 1 saat / 2 saat / Manuel
- **Bildirim sesi:** Switch
- **Titreşim:** Switch

"İleri" → kaydet, devam et.

#### Adım 6 — İlk Proje (opsiyonel)

- "Hemen başlayalım" başlığı
- Üç kart:
  - **Boş proje oluştur** → ad gir, dil seç, oluştur
  - **GitHub'dan klonla** → URL yapıştır
  - **Şimdi atla** → bu adımı geç
- Boş proje veya klonlama tamamlanırsa proje detay ekranına git
- Atlanırsa bir sonraki adıma

#### Adım 7 — Bitti

- Konfeti animasyonu (Lottie)
- "Her şey hazır! 🚀"
- Alt metin: "Bundan sonra her şeyi Harun Vibe Coding içinden yapabilirsin. Terminale hiç dokunmana gerek yok."
- Büyük "Uygulamaya Git" butonu → `/` (ana dashboard)

### 9.3 Sihirbazda Atlama ve Yeniden Çalıştırma

- İlk adımda "Atla" → ayarlarda "Kurulum Sihirbazını Tamamla" uyarısı sürekli görünür
- Ayarlar → Gelişmiş → "Sihirbazı Tekrar Çalıştır" → `POST /api/setup/reset` → yeniden başlat

---

## 10. Ekran-Ekran UX Spesifikasyonu

### 10.1 Boot / Splash (`/boot`)

Kurulum tamamlandıktan sonra her açılışta görülen kısa ekran.

**Akış:**
1. Server'ın çalıştığı kontrol edilir (`GET /api/health`, 400ms timeout)
2. Çalışıyorsa → 200ms fade out → `/`
3. Çalışmıyorsa → `TermuxBridge.runScript` ile `start.sh` gönderilir (background=true)
4. 500ms'de bir poll, 30 saniye boyunca
5. 30 saniye sonra hâlâ yoksa → hata paneli (Termux'u aç butonu, yeniden dene, ayarlar)

**UI:**
- Ortada logo + isim + sürüm
- Alt ortada ince progress bar (30 saniyenin nerede olduğunu gösterir)
- Durum metni: "Sunucu başlatılıyor…" / "Bağlanılıyor…" / "Hazır"
- Sunucu hazırsa yeşil nokta, değilse sarı

### 10.2 Ana Dashboard (`/`)

**Üst bar:**
- Sol: uygulama logosu + "Harun Vibe Coding"
- Sağ: bildirim zili (kırmızı rozet ile sayı), arama (global), profil/menü

**Widgetlar (dikey scroll):**

1. **Aktif Projeler Carousel** — Çalışan projelerin kartları, yatay scroll. Her kart: isim, port, mini log preview, "Aç/Durdur" butonu, tunnel durumu.

2. **Hızlı Eylemler Grid** — 3x2 grid:
   - Yeni Proje
   - GitHub'dan Klon
   - Yeni Sohbet (AI)
   - Terminal Aç
   - Son Yedekleme
   - Bildirimler

3. **Son Sohbetler Listesi** — En son 5 konuşma. Her biri: proje adı, AI provider ikonu, preview metni, timestamp.

4. **Sistem İstatistikleri Kartı** — CPU, RAM, Disk, Pil. Mini bar chart'lar.

5. **Bildirim Özeti** — Son 3 bildirim (varsa), "Tümünü gör" linki.

**Alt:** Bottom navigation (5 sekme)

**Pull-to-refresh:** tüm widget'ları yeniler

### 10.3 Projeler Listesi (`/projects`)

**Üst bar:**
- "Projeler" başlığı
- Sağ: arama, filtre, + (yeni), ... menü (yeniden sırala, dışa aktar)

**Filtre chipleri (scrollable):**
- "Tümü" / "Çalışanlar" / "Favoriler" / "Son Açılanlar" / env'e göre

**Liste:**
- `ListView.builder`, her proje `ProjectCard`
- Card içeriği:
  - Sol üst: env badge (renk + ikon)
  - Orta: proje adı (büyük), path (küçük gri), port numarası
  - Sağ üst: status noktası + duruma göre kısa yazı ("Çalışıyor", "Başlatılıyor", "Durdu", "Hata")
  - Sağ alt: favori yıldızı (dolu/boş)
  - Alt tarafta tunnel aktifse: mavi link chip ve kopyala ikonu
- **Swipe sağa:** başlat/durdur toggle (haptik feedback)
- **Swipe sola:** sil (kırmızı arka plan, onay gerekir)
- **Uzun basma:** bottom sheet context menu (Aç, Durdur, Tunnel, Log, Terminal, Yenile, Yedekle, Favori, Düzenle, Dışa Aktar, Sil)

**Boş durum:**
- Lottie animasyon (kutu)
- "Henüz proje yok. İlk projeni oluştur."
- Büyük "+" butonu

**FAB:** + (yeni proje) → bottom sheet modal açar (Git klon / ZIP / Boş)

### 10.4 Yeni Proje Sayfası (`/projects/new`)

Üstte 3 tab: **Boş Proje** / **GitHub'dan Klon** / **ZIP'ten Yükle**

**Boş Proje:**
- Ad (zorunlu)
- Dil/Ortam dropdown (otomatik tespit, manuel seçim) — flutter, react, nodejs, next, vue, python, flask, django, php, html, go, rust, ...
- Port (opsiyonel, boş bırakılırsa otomatik)
- Entry komut (opsiyonel, default'a güvenilir)
- Grup (opsiyonel, klasör gibi organize etmek için)
- AI ile tamamla (switch): "AI asistan başlangıç kodunu hazırlasın"
- "Oluştur" butonu

**GitHub'dan Klon:**
- Repo URL
- Branch (otomatik listelenir) — `/api/git/branches?repo=` ile uzak branch'ler gelir
- Ad (otomatik repo adından)
- Klon sonrası otomatik bağımlılık kurulumu (switch)
- Oluştur

**ZIP'ten Yükle:**
- "Dosya Seç" → file_picker
- ZIP seçilince önce boyut ve dosya sayısı göster
- Ad (otomatik dosya adından)
- Açıldıktan sonra env tespiti
- Yükle

Her durumda sonuç: proje detay sayfasına yönlendir.

### 10.5 Proje Detay (`/projects/:id`)

**Üst bar:**
- Geri, proje adı, sağda favori yıldızı, ... menü (Düzenle, Dışa Aktar, Sil)

**Ana içerik (scrollable):**

1. **Durum Kartı** — Büyük:
   - Sol: env badge büyük + ikon
   - Orta: durum (Çalışıyor / Durdu / Başlatılıyor / Hata)
   - Sağ: büyük Başlat/Durdur butonu (accent renkli)
   - Alt: port bilgisi, çalışma süresi (uptime), PID

2. **Tunnel Kartı** — (çalışıyorsa görünür)
   - "Public URL: https://xxx.trycloudflare.com"
   - Yan yana: Kopyala / Paylaş / QR Kod butonları
   - QR kod tıklanınca tam ekran modal açılır
   - Tunnel aktif değilse: "Public URL Aç" butonu

3. **Eylem Grid'i** — 3x2:
   - 📁 Dosyalar
   - 💬 AI Sohbet
   - 🖥 Terminal
   - 📋 Loglar
   - 🌿 Git
   - 💾 Yedekle

4. **Son Aktivite Zaman Çizelgesi** — Son 5 olay (git commit, dev server restart, yedek alındı, AI sohbet), timeline görünümü.

5. **Mini Log Önizleme** — Son 10 log satırı, "Tümünü Gör" linki.

6. **Proje Bilgileri** — Git repo, branch, disk boyutu, dosya sayısı, oluşturulma, son açılış.

### 10.6 Loglar (`/projects/:id/logs`)

**Üst bar:**
- Proje adı + "Loglar"
- Sağ: arama, duraklat/devam et, temizle, kaynak filtre (server / tunnel / tümü)

**İçerik:**
- `ListView.builder` ters yönde (en yeni altta)
- Her satır renkli: stderr kırmızımsı, stdout normal, info gri, warning sarı, error kırmızı
- Uzun basma: "AI'a sor" / "Kopyala" / "Metin olarak dışa aktar"
- ANSI renk kodları parse edilir
- Otomatik scroll (dibe yakınsa), kullanıcı yukarı scroll ettiyse durur
- Alt: "Alt satıra git" floating button (eğer scroll yukarıdaysa)

### 10.7 Git Paneli (`/projects/:id/git`)

**Üst bar:** Proje + "Git" + yenile

**Tab'lar:**
1. **Durum** — Değişen dosyalar (staged/unstaged/untracked), seçip commit
2. **Tarihçe** — Son 50 commit, timeline, her commit'te hash, mesaj, tarih, diff butonu
3. **Branch'ler** — Yerel + uzak, geçiş, oluştur, sil
4. **Diff** — İki ref arası, syntax-highlighted side-by-side (Monaco diff editor)

**Commit sheet (alt):**
- TextField: commit mesajı
- **"AI ile yaz"** butonu → `/api/ai/generate-commit-message` → öneri gelir, düzenlenebilir
- Seçili dosyaları göster
- Commit & Push / Commit butonları

### 10.8 Dosya Ağacı (`/files/:projectId`)

**Üst bar:**
- Proje dropdown (değiştirmek için)
- Arama ikonu, + (yeni dosya/klasör)

**İçerik:**
- `FileTreeNode` — recursive, lazy expand
- İkonlar uzantıya göre (utils/file_icons.dart)
- Klasörler üstte, dosyalar altta, alfabetik
- **Tap:** dosya → editöre git, klasör → expand/collapse
- **Uzun basma:** bottom sheet (Aç, Aç editörde, Yeniden adlandır, Kopyala, Kopyala yolu, Sil, AI'a açıkla, Sohbete ekle)
- **Swipe sola:** sil
- **Swipe sağa:** AI sohbetine ekle (context file)
- **Pull-to-refresh:** ağacı yeniler (fsnotify zaten otomatik yapar ama manuel de olsun)

**FAB:**
- Hafif basma: yeni dosya
- Uzun basma: seçenekler (yeni dosya, yeni klasör, AI ile oluştur)

### 10.9 Editör (`/files/:projectId/edit?path=...`)

**Üst bar:**
- Geri, dosya adı (path breadcrumb), değiştirildi işareti (●)
- Sağ: Kaydet, Undo/Redo, Ara/Değiştir, Format, ... menü (AI açıkla, AI düzelt, dosyayı diff ile göster, Git blame)

**Ana alan:**
- Monaco WebView tam ekran
- Alt durum çubuğu: satır:sütun, dil, boyut, UTF-8, kaydetme durumu
- Klavye açıkken custom toolbar görünür: Tab, Ctrl, oklar, Esc, { } ; " '

**Sağ drawer** (swipe ile açılır):
- Mini dosya ağacı (hızlı navigasyon)
- Son açılan dosyalar
- Kaydedilmemiş dosya listesi

**AI entegrasyon:**
- Editörde metin seç → context menüde "AI'a açıkla" / "AI'a düzelt" / "AI'a yazdır (devam)"
- AI paneli alttan açılır (bottom sheet), sonucu dönem editöre uygula

### 10.10 Terminal (`/terminal`)

**Üst bar:**
- "Terminal" + açık tab sayısı
- + (yeni), menü (cwd değiştir, yazı boyutu, renk şeması, tümünü kapat)

**Tab bar (altta üstte, xterm'in üstünde):**
- Her tab'da: cwd'nin son segmenti (örn "projects/myapp"), kapat X
- Tab'a tap: geç
- Uzun basma: sheet (Yeniden adlandır, Kapat)
- + tab: yeni terminal aç → cwd seçici

**Ana alan:**
- `XtermView` tam ekran (klavye üstü hariç)
- ANSI renkler, 256 color desteği
- Uzun basma: kopyala/yapıştır menüsü
- Çift tap: kelime seç

**Alt klavye yardımcısı (VirtualKeyboard):**
Üst sıra: Esc | Tab | Ctrl | Alt | ↑ | ↓ | ← | → | Home | End | PgUp | PgDn
Alt sıra: ~ | / | \ | | | < | > | ; | " | ' | { } | [ ] | ( )

Ctrl tuşu "sticky": basılı kalır, sonraki karakter ile kombine olur.

### 10.11 AI Ana Sayfa (`/chat`)

Üstte tab bar: **Projeler** | **Sohbetler** | **Kütüphane** | **Kullanım**

**Projeler tab:**
- Her proje için kart:
  - Proje adı
  - Aktif sohbet sayısı (Claude: N, Gemini: M)
  - Hızlı aksiyonlar: "Yeni Claude", "Yeni Gemini", "Son Sohbete Devam Et"
  - Tap: son sohbete git veya yeni başlat

**Sohbetler tab:**
- `/api/conversations` — tüm sohbetler, en yeni üstte
- Zaman gruplaması: "Bugün", "Dün", "Bu hafta", "Daha eski"
- Her sohbet: proje adı, AI provider ikonu, başlık (AI ilk cevaptan üretir), son mesaj preview, timestamp, mesaj sayısı, toplam maliyet
- **Tap:** sohbete git (/chat/:id)
- **Uzun basma:** sheet (Devam et, Dışa aktar markdown, Özetle yeni sohbet, Başka AI'a fork et, Sil)

**Kütüphane tab:**
- Kaydedilmiş prompt'lar (prompt library)
- Her prompt: başlık, içerik preview, tag'ler, son kullanım
- + yeni prompt → bottom sheet ile ekle

**Kullanım tab:**
- Token maliyeti dashboard
- Grafikler (fl_chart):
  - Günlük token kullanımı (bar chart, 30 gün)
  - Maliyet trendi (line chart)
  - Proje başına dağılım (pie chart)
- Toplam: bu hafta, bu ay, tüm zamanlar
- Model başına kırılım

### 10.12 Sohbet Oturumu (`/chat/:id`) — **Bu bölüm en detaylı**

Bkz. Bölüm 11. Bu ekran tam bir özellik patlaması.

### 10.13 Yedekler (`/backups`)

**Üst bar:**
- "Yedekler" + filtre (proje, tip, tarih)
- Sağ: + (manuel yedek), bulut bağla, ayarlar

**İçerik:**
- Timeline görünümü (günler gruplanmış)
- Her yedek kartı:
  - Sol: tip ikonu (ZIP / Git / Cloud)
  - Orta: proje adı, tarih, boyut, tetikleyici (otomatik / manuel / pre-AI)
  - Sağ: aksiyonlar (Geri Yükle, İndir, Sil)
- **Tap:** detay sayfası
- **Uzun basma:** hızlı eylem

**Yedek detay:**
- Dosya listesi (ZIP içindekiler)
- Geri yükleme seçenekleri:
  - "Mevcut projeyi üstüne yaz" (onay gerekir)
  - "Yeni proje olarak aç" (isim değiştirilir)
- Commit hash (git ise) — belirli bir commit'e dön

### 10.14 Bildirimler (`/notifications`)

**Üst bar:** "Bildirimler" + tümünü okundu + ayarlar

**İçerik:**
- Kategorilere göre gruplanmış (AI, Sunucu, Yedekleme, Sistem)
- Her bildirim: ikon, başlık, body, timestamp, aksiyon butonları
- **Tap:** deep link'e git (örn sohbete, proje detayına)
- **Swipe sola:** okundu olarak işaretle / sil

### 10.15 Ayarlar (`/settings`)

Liste görünümü, her giriş alt sayfaya götürür:

- **Görünüm** → tema, accent, font, boyutlar
- **Editör** → tab boyutu, word wrap, auto-save, minimap, satır no
- **Terminal** → cursor stili, boyut, renk, bell
- **Sohbet** → quick actions, enter davranışı, thinking göster
- **Yedekleme** → otomatik, sıklık, saklama, git, bulut
- **Bildirimler** → kategoriler, ses, titreşim
- **AI** → CLI kurulum/login durumu (Claude + Gemini), varsayılan provider/model, sistem prompt, izin kuralları, abonelik durumu bilgisi, çıkış/yeniden giriş
- **Sunucu** → base URL, port, bağlantı testi, start.sh yolu
- **Gelişmiş** → önbellek temizle, sihirbazı tekrar çalıştır, log seviyesi, deneysel
- **Hakkında** → sürüm, lisans, GitHub, geri bildirim

---

## 11. Vibe Coding Sohbet Bölümü — Gelişmiş Özellikler

Bu bölüm uygulamanın en öne çıkan kısmı. Sıradan bir sohbetten çok daha fazlasını sunar.

### 11.0 AI Entegrasyon Mimarisi — CLI Subprocess

**KRİTİK:** Harun Vibe Coding, Claude ve Gemini'ye **doğrudan API çağrısı yapmaz**. Bunun yerine resmi CLI'ları subprocess olarak yönetir.

**Nedenleri:**
- Kullanıcı Claude Pro/Max/Team ve Gemini aboneliğiyle giriş yapar, API key ödemez
- CLI'lar OAuth/session token yönetimini kendi yapar, biz dokunmayız
- CLI'lar tool calling, streaming, stop reason gibi protokol detaylarını sağlar
- Rate limit, retry, error handling CLI katmanında zaten çözülmüş
- Abonelik kotası otomatik olarak kullanıcının hesabından düşer

#### 11.0.1 CLI Komutları (Backend subprocess çağrıları)

**Claude Code CLI — headless / programatik mod:**

```bash
claude --print \
  --output-format stream-json \
  --input-format stream-json \
  --model claude-sonnet-4-5 \
  --permission-mode plan \
  --allowedTools "Read Edit Write Bash Glob Grep" \
  --add-dir /path/to/project \
  --session-id <uuid> \
  "kullanıcı mesajı"
```

- `--output-format stream-json`: satır satır JSON event akışı (chat.start, chat.text_delta, chat.tool_use, chat.tool_result, chat.done)
- `--input-format stream-json`: stdin'den de JSON event gönderebiliriz (çoklu tur, abort)
- `--permission-mode plan`: tool izinleri bizim tarafımızdan karar verilir (CLI sadece sorar, biz cevaplarız)
- `--session-id`: önceki oturumu devam ettirmek için
- `--resume <id>`: kesilmiş sohbete devam

**Gemini CLI — non-interactive mod:**

```bash
gemini --prompt "kullanıcı mesajı" \
  --model gemini-2.5-pro \
  --output-format json \
  --yolo=false \
  --include-directories /path/to/project \
  --checkpointing \
  --session-resume <id>
```

- `--output-format json`: structured event akışı
- `--yolo=false`: tüm tool'lar için izin sor
- `--checkpointing`: AI değişikliklerinden önce otomatik checkpoint

#### 11.0.2 Backend Tarafı Bridge — `internal/domain/ai/`

```
ai/
├── service.go              # Unified interface (Chat, AbortChat, ListSessions)
├── cli_claude.go           # Claude CLI wrapper (exec.Cmd + pty.Start)
├── cli_gemini.go           # Gemini CLI wrapper
├── session_manager.go      # Açık CLI subprocess'lerini izler
├── event_parser.go         # CLI stdout JSON → domain event
├── event_translator.go     # Claude/Gemini event farklılıklarını unified formata çevirir
├── permission_gate.go      # Tool call → Flutter'a izin sor → cevabı CLI'a ilet
├── context_injector.go     # @mention, context files → prompt'a ekleme
└── cost_observer.go        # CLI'dan gelen token/cost bilgisini kaydet
```

**Akış:**

1. Flutter WebSocket'ten gönderir: `{"type":"chat.input","payload":{"provider":"claude","text":"..."}}`
2. `ai.Service.Chat(ctx, req)` çağrılır
3. `session_manager` mevcut session var mı kontrol eder; yoksa yeni `exec.Cmd` başlatır (pty ile sarılır çünkü Claude Code interaktif TTY bekler)
4. stdin'e kullanıcı mesajı yazılır (stream-json formatında)
5. stdout goroutine satır satır okur, her satır JSON parse edilir
6. Event'ler `event_translator` ile unified formata çevrilir (örn Claude'un `tool_use_id` → bizim `tool_call_id`)
7. WebSocket'e push edilir (Section 6.5.1'deki mesaj tipleriyle)
8. Tool call geldiğinde `permission_gate` devreye girer:
   - Otomatik izin kuralları varsa hemen "allow" döner
   - Yoksa Flutter'a `chat.permission_request` push eder, cevabı bekler
   - Cevap gelince CLI'a stdin üzerinden ilet (Claude Code: `{"type":"permission_response","allow":true}`)
9. `chat.done` event'i gelince session kapanır (veya açık kalır, multi-turn için)

#### 11.0.3 Session Yönetimi

- Her Flutter conversation bir CLI session'a bağlı
- Session uzun yaşar: çoklu turn, background'a atılsa bile
- Abort: `kill -TERM pid` ile temiz durdurma
- Crash: panic olursa kullanıcıya gösterilir, "Yeniden Dene" butonu

#### 11.0.4 Model Değiştirme

- Mid-conversation model değişimi Claude Code'da: `/model opus-4-7` slash command (CLI destekliyor, geçiriyoruz)
- Gemini için: yeni session başlatılır (CLI mid-conversation model değişimi desteklemiyor)
- Flutter UI'da "Model değişimi yeni oturum gerektirir" uyarısı gösterilir gerektiğinde

#### 11.0.5 CLI Olmadığında Davranış

- Uygulama açılışında `which claude` ve `which gemini` ile tespit
- Biri eksikse o provider Setup/Settings'te "yüklü değil" rozeti gösterir
- İkisi de yoksa uygulama çalışır ama AI sekmesi "CLI kurulu değil, Ayarlar'dan kur" CTA'sı gösterir
- Başka özellikler (editor, terminal, git, dev server) AI olmadan çalışır

---

### 11.1 Sohbet Oturumu Genel Yapı (`/chat/:id`)

Ekran dört bölgeye ayrılır:

```
┌─────────────────────────────────────┐
│  Üst bar (proje, AI, başlık, menü)  │
├─────────────────────────────────────┤
│  ThinkingBar (sticky, opsiyonel)    │
├─────────────────────────────────────┤
│                                     │
│        Mesaj listesi (scrollable)   │
│        (reverse ListView)           │
│                                     │
├─────────────────────────────────────┤
│  ContextFilesPanel (genişletilir)   │
├─────────────────────────────────────┤
│  Quick actions bar                  │
├─────────────────────────────────────┤
│  Input bar + eklentiler             │
└─────────────────────────────────────┘
```

### 11.2 Üst Bar

- Sol: geri ok
- Orta: proje adı (küçük, üstte) + AI ikonu (Claude / Gemini) + başlık (büyük)
- Sağ: 
  - Model seçici (dropdown, sohbet ortasında bile değiştirilebilir ama uyarı: "Model değişimi yeni sohbet başlatır")
  - ... menü (Sohbeti sil, Markdown dışa aktar, Özetle & Yeni Sohbet, Başka AI'a fork et, Bu noktadan branch oluştur, Ayarlar)

### 11.3 ThinkingBar (Sticky Üst)

Sadece `chat.thinking` event'leri geldiğinde görünür, kaybolurken animasyon.

- Sol: pulse animasyonu (üç nokta)
- Orta: "Düşünüyor..." + son thinking delta'sının kısa preview'u
- Sağ: süre sayacı ("2.3s")
- Tap: genişler, full thinking content'i göster (Claude extended thinking kullanılıyorsa)

### 11.4 Mesaj Listesi — Bubble Tipleri

Reverse ListView, en son mesaj altta.

#### 11.4.1 UserMessage

- Sağa yaslı, accent gradient balon
- İçerik: text (markdown desteği yok — raw göster, daha doğal)
- Alt sağ: timestamp, "Düzenle" (uzun basma ile), "Tekrar Gönder"
- Eğer context files vardıysa: altta küçük chip'ler ("lib/main.dart", "pubspec.yaml")
- Eğer resim eklendiyse: önizleme

#### 11.4.2 AssistantMessage

- Sola yaslı, surface renkli balon
- Markdown render: başlıklar, listeler, kalın/italik, link
- Kod blokları özel bileşende:
  - `CodeBlockCard`:
    - Üst bar: dil adı, kopyala butonu, **"Dosyaya kaydet"**, **"Terminalde çalıştır"**, **"Diff olarak göster"**
    - Syntax highlight (JetBrainsMono, dracula)
    - Uzun kod blokları collapsible (5+ satır)
- Alt tarafta: `StatsFooter` (süre, token, maliyet — küçük gri)
- Uzun basma: kopyala, tüm mesajı kopyala, AI'a yeniden sor, "Dosyalara yaz" (eğer mesajda dosya içeriği varsa toplu uygula)

#### 11.4.3 ToolCallCard

Tool çağrısı geldiğinde AssistantMessage'ın içinde inline görünür:

- Collapsed default: ikon + tool adı (örn "📄 read_file") + "lib/main.dart" (input'un özeti)
- Tap: genişler, tam input JSON'u göster (syntax-highlighted)
- Sağda mini action: `Edit` / `Write` tool'ları için **"Önizle"** butonu → diff viewer açılır

#### 11.4.4 ToolResultCard

ToolCallCard'ın hemen altında:

- Başarılıysa: yeşil ✓ + "Tamamlandı" + süre
- Hatayla ise: kırmızı ✗ + hata özeti
- Collapsed default (uzun çıktı), tap ile genişler
- `Bash` tool sonucu ANSI renklerle render edilir
- `Read` tool sonucu: dosya içeriği syntax-highlighted preview (ilk 50 satır, "Devamı" butonu)

#### 11.4.5 ToolDiffCard (Gelişmiş)

Eğer tool `Edit` veya `Write` ise ve kullanıcı önizledi ise:

- Monaco diff editor (küçük ekranda yığılmış, büyük ekranda side-by-side)
- Üst: dosya yolu
- Alt: "Uygula" / "Reddet" / "Düzenle" butonları
- Uygula → `chat.tool_decision` gönderilir
- Düzenle → Monaco düzenlenebilir moda geçer, kullanıcı manuel değişiklik yapar, sonra uygula

### 11.5 Permission Dialog

`chat.permission_request` geldiğinde bottom sheet modal açılır:

**Başlık:** "Claude bir işlem için izin istiyor"

**İçerik:**
- Tool adı büyük yazı (örn "write_file")
- Kısa açıklama ("Yeni bir dosya oluşturacak veya mevcut olanı üzerine yazacak")
- Preview:
  - `read_file` ise: "Okunacak dosya: lib/main.dart"
  - `write_file` / `edit_file` ise: diff viewer (kısaltılmış)
  - `bash` ise: çalışacak komut, syntax-highlighted
- Tehlike seviyesi göstergesi (yeşil/sarı/kırmızı şerit)

**Butonlar:**
- "Reddet" (gri)
- "Bir kez izin ver" (accent outline)
- "Her zaman izin ver" (accent dolu) — dropdown ile scope: bu tool / bu proje / tüm projeler

**Alt:** 
- "İzin kurallarını yönet" linki → settings sayfası

### 11.6 Context Files Panel

Input alanının üstünde (collapsible):

- Başlık: "📎 Eklenen Dosyalar (3)"
- Chip'ler: her biri dosya adı + X (kaldır)
- + butonu: dosya ekle (dosya ağacından seç)
- **@mention desteği**: input'ta `@` yazınca dropdown açılır, proje dosyaları filtrelenir, tap ile eklenir

**Neden önemli:** Token tasarrufu + daha isabetli cevap. AI sadece seçilen dosyaları okur, tüm projeyi taramaz.

### 11.7 Quick Actions Bar

Input'un hemen üstünde, yatay scrollable:

Varsayılan butonlar (kullanıcı özelleştirebilir):
- 🔄 Devam et
- 🔁 Tekrar dene
- 📋 Özet ver
- 💡 Açıkla
- 🔧 Düzelt
- 🧪 Test yaz
- ⚡ /compact (geçmişi sıkıştır)
- 🧹 /clear (yeni sohbet)
- 📂 Dosyaları listele

Ayarlardan ekle/çıkar/sırala.

### 11.8 Input Bar — Zengin

Alt kısım:

```
┌──────────────────────────────────────────┐
│  📎 🎤 📷 /                              │   ← Eklenti butonları + slash
│  [TextField — çok satırlı, auto-resize]  │
│                                    [↑]   │   ← Gönder
└──────────────────────────────────────────┘
```

- **📎 Ek:** dosya ekle (context file), resim ekle (galeriden), ekran görüntüsü al
- **🎤 Mikrofon:** basılı tut → dinle (Android SpeechRecognizer), bırak → transkripsiyon input'a düşer, düzenleyip gönder
- **📷 Ekran görüntüsü:** uygulama içi screenshot → input'a ek
- **/** : slash command menüsü açılır (aşağıda)
- **TextField:** 1-6 satır auto-resize, Türkçe IME tam destek, Shift+Enter = yeni satır
- **↑:** gönder (veya durdur, stream sırasında)

### 11.9 Slash Commands

`/` yazınca üstte dropdown açılır, filtrelenebilir liste:

| Komut | Açıklama |
|---|---|
| `/commit` | Git diff'ten commit mesajı üret |
| `/test` | Son değişiklikler için test yaz |
| `/lint` | Linter çalıştır ve hataları göster |
| `/diff` | Son N dakikadaki değişikliklerin diff'i |
| `/undo` | Son AI değişikliğini geri al |
| `/context dosya.py` | Dosya context'e ekle |
| `/unload dosya.py` | Dosyayı context'ten çıkar |
| `/run npm test` | Komutu terminalde çalıştır ve çıktıyı göster |
| `/screenshot` | Ekran görüntüsünü ekle |
| `/clear` | Sohbeti temizle |
| `/compact` | Uzun sohbeti özetle |
| `/model opus` | Modeli değiştir |
| `/branch <commit>` | O noktadan yeni sohbet fork'la |
| `/export` | Markdown olarak dışa aktar |
| `/tokens` | Kalan token bütçesi |
| `/explain` | Son asistan mesajını basitçe tekrar açıkla |

### 11.10 Dosya Bağlamı (Context Management)

Üç yolla context dosyası eklenir:
1. **Elle:** Context Files Panel'den + butonu
2. **@mention:** Input'ta yazarak
3. **Sürükle-bırak:** Dosya ağacından sohbete (büyük ekranlarda)
4. **Slash:** `/context path`

Context dosyaları:
- **Inline preview:** chip'e basınca alttan genişler, dosya içeriği sayfalanır
- **Token sayacı:** her dosya kaç token, toplam ne kadar
- **Auto-exclude:** büyük dosyalar (500KB+) uyarı verir, eklemek istersen onay
- **Smart suggest:** AI "bu dosyayı da göreyim" derse popup: "Claude şunu istiyor: `lib/api.dart`. Eklememi ister misin?"

### 11.11 Diff Viewer (Gömülü)

Monaco diff editor, bottom sheet olarak:

- Üst: dosya yolu
- Orta: side-by-side diff (ekran dik moddayken unified, yatayda side-by-side)
- Alt: "Uygula", "Reddet", "Düzenle"
- "Düzenle" modunda sağ taraf editable olur, kullanıcı ince ayar yapar

Diff syntax: ekleme yeşil, silme kırmızı, değişen sarı. Whitespace görünürlüğü toggle.

### 11.12 Checkpoint Sistemi (AI Öncesi)

**Otomatik:** AI her dosya yazma/düzenleme öncesinde otomatik git checkpoint oluşturur:
- Git repo varsa: `git add -A && git commit -m "[HVC-CP] Before AI edit"` (özel branch: `hvc/checkpoints`)
- Git repo yoksa: ZIP snapshot: `~/HarunVibeCoding/backups/<project>/.pre-ai-<timestamp>.zip`

**Manuel:**
- Sohbet üst menüsünde "🕒 Checkpoint Oluştur"
- "Checkpoint'e Dön" → son N checkpoint listelenir

**UI:**
- Her AssistantMessage altında küçük "↶ Bu noktaya geri dön" butonu (eğer dosya değiştirdiyse)
- Tap: onay modal → checkpoint'e geri dön, sohbeti o anda fork'la

### 11.13 Hibrit AI Modu

Aynı anda Claude + Gemini'ye aynı soruyu sormak için özel mod.

**Tetikleme:**
- Sohbet ekranında üst menüden "Hibrit Mod"
- Veya slash: `/hybrid`

**UX:**
- Ekran 2'ye bölünür: sol Claude, sağ Gemini
- Input tek (her ikisine aynı mesaj gider)
- Cevaplar paralel stream edilir, yan yana görünür
- Alt: "Claude cevabını seç" / "Gemini cevabını seç" / "Birleştir" butonları
- Seçilen cevap ana sohbete kaydedilir, diğeri atılır (veya istersen iki sohbet de saklanır)

**Alternatif rol paylaşımı:**
- "Plan için Gemini, kod için Claude" gibi preset
- Ayarlardan tanımla

### 11.14 Sesli Giriş

Mikrofon butonu basılı tutulduğunda:
- Android native `SpeechRecognizer` çalışır
- Gerçek zamanlı transkripsiyon (partial results) input'ta görünür
- Bırakınca final transcript yerleşir
- Kullanıcı düzenleyip gönderir

Ayrıca:
- **Auto-send modu** (ayarlardan): bırakınca direkt gönder
- **Sürekli mod**: tap ile aç, tekrar tap ile kapat

Dil: Türkçe (`tr-TR`), ayarlardan değiştirilebilir.

### 11.15 Görsel Destek

- Galeriden resim ekle
- Kameradan fotoğraf çek
- Ekran görüntüsü al (uygulama içi)
- Uzun basınca kopyalanmış resmi yapıştır

Resim mesaj balonunda thumbnail olarak görünür, tap ile büyür. Claude/Gemini görür ve analiz eder.

**Akıllı kullanım:** hata ekranı → screenshot → AI'a "bu hatayı çöz"

### 11.16 Prompt Kütüphanesi

`/chat/prompts` ekranı:
- Kullanıcının kaydettiği sık prompt'lar
- Kategorilere göre: "Kurulum", "Bug Fix", "Code Review", "Özellik Ekle"...
- Tag'lerle arama

**Kullanım:**
- Sohbet input'unda sol üst + butonuna basınca "Kütüphaneden seç"
- Seçilen prompt input'a düşer, değişken yerleri varsa (örn `{{file_path}}`) doldurulur
- Gönder

Varsayılan birkaç prompt gelir (constants/default_prompts.dart):
- "Bu kodu TypeScript'e çevir"
- "Bu dosyayı test et"
- "Performans problemi var mı, incele"
- "README yaz"
- "Refactor et, temiz kod"
- "Bu hatayı çöz"

### 11.17 Sohbet Özetleme (Compact)

Uzun sohbetler bir süre sonra token limiti aşmaya başlar. `/compact` veya menü:

- Arka planda AI'a özet istenir
- Özet + son 5 mesaj korunur, geri kalanı silinir
- Token tasarrufu %70+

Alternatif: **"Özetle & Yeni Sohbet"** — mevcut sohbeti özetle, yeni sohbet aç, özeti sistem prompt olarak ekle.

### 11.18 Sohbetler Arası Köprü (Fork)

- "Başka AI'a fork et" → Claude sohbeti Gemini'de devam edebilir
- Mevcut geçmiş yeni AI'ın sistem prompt'una özet olarak eklenir
- Yeni konuşmada sanki kaldığı yerden devam

### 11.19 Ses Bildirimi (İşlem Bitti)

- AI uzun iş yapıyorsa (30+ saniye) kullanıcı telefonu bırakıp başka işe dönebilir
- İş bitince:
  - Uygulama arka planda: bildirim çalar + titreşir
  - Uygulama önde: yumuşak tık sesi (ayardan kapatılabilir)

Detay: Bölüm 13.

### 11.20 Token & Maliyet Göstergesi

Sohbet ekranının alt ortasında küçük chip:
- "12.3K tok • $0.045"
- Tap: detaylı breakdown (input / output / cache)

`/chat/usage` sayfasında:
- Tüm zamanlar toplam
- Bu ay / bu hafta / bugün
- Proje başına
- Model başına
- Saatlik/günlük grafik
- Bütçe alarmı: "$10/ay" → aşınca uyarı

### 11.21 Davranışsal Bellek (Memory)

Kullanıcı "bunu hep hatırla" dediği şeyleri saklar:
- `/remember: npm yerine pnpm kullan`
- Tüm yeni sohbetlerin sistem prompt'una eklenir
- Ayarlar → AI → Memory sayfasından düzenlenir/silinir
- Proje-scoped veya global scope

### 11.22 Hata Yardımcısı (Error Helper)

Log ekranındaki herhangi bir hata satırı uzun basılınca:
- "AI'a sor" → otomatik olarak:
  - Son 50 log satırı
  - Hata satırı
  - İlgili dosyalar (stacktrace'den çıkarılmış)
- Tek dokunuş → AI hata analizi

### 11.23 Kod Bloğu Aksiyonları (Detaylı)

AssistantMessage içindeki her kod bloğu için:

| Aksiyon | Davranış |
|---|---|
| Kopyala | Clipboard'a |
| Dosyaya kaydet | Path sor → kaydet, fsnotify tetiklenir |
| Terminal'de çalıştır | Yeni terminal sekmesi aç, komutu yapıştır |
| Diff olarak göster | Mevcut dosyayla karşılaştır, diff bottom sheet |
| Apply all (toplu) | Mesaj birden fazla kod bloğu varsa, hepsini ilgili dosyalara yaz |
| Dili değiştir | Syntax highlight dili farklıysa manuel seç |

---

## 12. Yedekleme Sistemi

### 12.1 Üç Katman

**1. Local ZIP** — Periyodik otomatik veya manuel
- Konum: `~/HarunVibeCoding/backups/<project_slug>/<timestamp>.zip`
- Sıkıştırma: zip deflate
- Hariç: `node_modules`, `.git/objects`, `build`, `dist`, `__pycache__`, `.venv`, `vendor`, `.next`
- Saklama: varsayılan son 20 yedek, eski silinir
- Boyut: tipik 1-50MB

**2. Git Checkpoint** — Versiyonlu
- Özel branch: `hvc/checkpoints`
- Her checkpoint: `git add -A && git commit -m "[HVC] <reason> <timestamp>"`
- Tetikleyiciler: her AI dosya değişimi öncesi, manuel, zamanlanmış
- `git reflog` ile her şey izlenebilir
- Geri dönüş: `git checkout <hash>` veya branch üzerinden

**3. Cloud Backup (Opsiyonel)** — Google Drive veya Dropbox
- OAuth ile hesap bağlanır
- Lokalde alınan ZIP'ler periyodik olarak buluta yüklenir
- Konum: `HarunVibeCoding/<device_name>/<project>/<timestamp>.zip`
- Retention: bulutta da sınırlı (ayarlardan)
- Sadece WiFi'de yükle opsiyonu

### 12.2 Ayarlar

- **Otomatik yedekleme:** on/off
- **Sıklık:** 15 dk / 30 dk / 1 saat / 2 saat / 6 saat / 24 saat
- **Trigger'lar (çoklu seçim):**
  - Dev server durdurulurken
  - Git commit'ten sonra
  - AI dosya değişiminden önce
  - Proje silinmeden önce (ZORUNLU — override edilemez)
  - Zamanlanmış (yukarıdaki aralık)
- **Lokal saklama:** son N yedek (5/10/20/50)
- **Git checkpoint:** on/off
- **Bulut:** bağlı/değil, sadece WiFi

### 12.3 Geri Yükleme Akışları

**Tam geri yükleme:**
- Yedek detay ekranı → "Geri Yükle"
- İki mod:
  - **Üstüne yaz** (mevcut projeyi tamamen değiştir) — onay istenir, mevcut durum otomatik yedeklenir
  - **Yeni proje olarak aç** — isim sor, bağımsız kopya

**Kısmi geri yükleme:**
- Yedek detayında dosya listesi
- Sadece seçili dosyaları geri yükle
- Diff görüntüle seçeneği — yedekteki vs mevcut

**Git checkpoint'e dön:**
- Git paneli → Tarihçe → [HVC] etiketli commit'ler vurgulanır
- "Bu noktaya dön" → onay → `git reset --hard <hash>`
- Öncesinde WIP checkpoint otomatik alınır

### 12.4 Bildirimler

- Otomatik yedek alındı: sessiz / kanal `hvc_backup`
- Yedek başarısız: normal / kanal `hvc_system`
- Disk dolu / yedek alamıyor: yüksek / kanal `hvc_system`

---

## 13. Bildirim Sistemi

### 13.1 Bildirim Kategorileri ve Tetikleyiciler

| Kategori | Tetikleyici | Kanal | Önem |
|---|---|---|---|
| AI Cevabı Hazır | Arka planda iken sohbet yanıtı tamamlandı | `hvc_ai_response` | NORMAL |
| AI İzin İstiyor | Tool permission request, uygulama arka planda | `hvc_ai_permission` | HIGH |
| AI Hatası | Rate limit, API hatası, abort | `hvc_ai_response` | NORMAL |
| Dev Server Hazır | Proje başlatıldı, port dinliyor | `hvc_service` | LOW |
| Dev Server Hatası | Crash, exit code ≠ 0 | `hvc_server_error` | HIGH |
| Dev Server Durdu | Beklenmedik kapanma | `hvc_server_error` | NORMAL |
| Tunnel Hazır | Public URL üretildi | `hvc_tunnel` | NORMAL |
| Tunnel Koptu | Cloudflared disconnect | `hvc_tunnel` | LOW |
| Yedekleme Tamamlandı | Auto backup OK | `hvc_backup` | MIN |
| Yedekleme Başarısız | Disk/ağ hatası | `hvc_system` | NORMAL |
| Disk Dolu | < 500MB kaldı | `hvc_system` | HIGH |
| Pil Düşük (sunucu çalışıyor) | < %15, sunucu aktif | `hvc_system` | NORMAL |
| Setup Gerekli | CLI login expired / CLI kaldırıldı | `hvc_system` | NORMAL |
| Büyük İş Tamamlandı | 30+ saniye süren AI işi bitti | `hvc_ai_response` | NORMAL |
| Git Push Başarılı | Commit push edildi | `hvc_service` | LOW |
| Yeni Sürüm Var | GitHub release kontrolü (opsiyonel) | `hvc_system` | LOW |

### 13.2 Bildirim Aksiyonları

Her bildirim 0-3 aksiyon içerebilir. Örnekler:

**AI İzin İstiyor:**
- "İzin Ver" (direkt tool çalıştır)
- "Reddet" (tool iptal)
- "Uygulamada Aç" (deep link)

**Dev Server Hatası:**
- "Logları Aç"
- "Yeniden Başlat"
- "AI'a Sor" (hata analizi)

**Tunnel Hazır:**
- "URL'yi Paylaş" (share intent)
- "Kopyala"

**Yedekleme Başarısız:**
- "Ayarları Aç"
- "Tekrar Dene"

### 13.3 Deep Linking

Her bildirim `deep_link` alanı içerir, tap edilince:
- `/chat/conv_abc` → o sohbete git
- `/projects/proj_x/logs` → log ekranı
- `/backups` → yedek listesi

### 13.4 Sessiz Saatler

Ayarlardan:
- "Gece sessiz": 23:00-08:00 arası sadece HIGH kanalı ses çıkarır
- Özel aralıklar tanımlanabilir

### 13.5 Bildirim Merkezi (`/notifications`)

- Tüm bildirimler (hem Android'e gönderilen hem sadece in-app)
- Okundu/okunmadı
- Kategori gruplaması
- Arama, filtre
- Uzun basma: aksiyonlar, sil

### 13.6 Backend Tarafı — Event → Bildirim

Go tarafında `notifications.Dispatcher`:

- Her önemli olay `dispatcher.Post(notif)` ile gelir
- Rule engine (`rules.go`) kontrol eder:
  - Kullanıcı bu kategoriyi istiyor mu?
  - Sessiz saatlerde miyiz?
  - Rate limit (aynı tip bildirim dakikada max N kez)
  - Uygulama önde mi arkada mı (öndeyken bazıları sessiz)
- WebSocket `events` kanalından Flutter'a push
- Flutter tarafı `NotificationBridge.postNotification(...)` ile sisteme düşer

### 13.7 Servis Bildirimi (Foreground)

Arka planda çalışırken sürekli görünür bildirim:
- Başlık: "Harun Vibe Coding"
- Body: dinamik ("2 proje çalışıyor • 1 AI sohbet aktif")
- Tap: uygulamayı öne getirir
- Eylem butonları: "Tümünü Durdur", "Ana Menü"

Ayarlardan arka plan servisi kapatılabilir (önerilmez).

---

## 14. Terminal (Gömülü)

Bu kısım Bölüm 10.10'da UX açısından anlatıldı. Burada teknik detay:

### 14.1 Backend (Go)

`internal/domain/terminal/` paketinde:

- `NewSession(cwd, cols, rows, shell)` — `pty.Start()` ile bash fork
- Her session'ın ayrı bir `io.ReadWriter` PTY master'ı var
- Goroutine: master'dan oku, `session.OutputCh` kanalına yaz
- WebSocket handler `OutputCh`'den dinler, client'a push eder
- Resize: `pty.Setsize(master, &pty.Winsize{Rows, Cols})`
- Kapama: `process.Signal(syscall.SIGHUP)` + fd close

### 14.2 Flutter (xterm.dart)

```
[User keyboard] 
    ↓
[TerminalView.onInput(String)]
    ↓
[WsClient.send({"type":"terminal.input","data":"..."})]
    ↓
[WebSocket]
    ↓
[Backend PTY master.Write]
    ↓
[Shell process]
    ↓
[Backend PTY master.Read]
    ↓
[WebSocket push: {"type":"terminal.data","data":"..."}]
    ↓
[Terminal.write(data)]
    ↓
[xterm render]
```

- `Terminal` instance → her tab için ayrı
- `TerminalView` widget
- `Terminal.onOutput = (data) => ws.sendTerminalInput(sid, data);`
- `Terminal.onResize = (c, r) => ws.sendTerminalResize(sid, c, r);`

### 14.3 Klavye Yardımcısı

Terminal klavyesiyle birlikte Flutter tarafında özel bir row:
- Ctrl (sticky), Esc, Tab, oklar, özel karakterler
- Her buton tap → uygun escape sequence gönder
  - Esc → `\x1b`
  - Ctrl+C → `\x03`
  - ↑ → `\x1b[A`
  - Tab → `\t`

### 14.4 Multi-tab ve Persist

- Uygulama kapansa bile backend terminal'leri çalışmaya devam eder (foreground service)
- Yeniden bağlanınca tüm aktif terminaller listelenir, kullanıcı seçerek geri döner
- Buffer: backend son 10.000 satırı tutar, reattach'ta yeniden stream eder

---

## 15. Monaco Kod Editörü Entegrasyonu

### 15.1 Neden Monaco + WebView

Native Flutter editör paketleri (re_editor, code_text_field) büyük dosyada, çoklu imleçte, find/replace'te, IME'de yetersiz. Monaco VS Code kalitesinde editördür ve hepsi çözer.

### 15.2 Varlık Hazırlığı

`assets/monaco/` klasörüne Monaco dağıtımının minified versiyonu konur (~15MB):
- `index.html`
- `vs/loader.js`
- `vs/editor/editor.main.js`
- `vs/editor/editor.main.css`
- `vs/base/worker/workerMain.js`
- Dil servisleri (sadece kullanılanlar: dart, typescript, javascript, python, go, rust, java, html, css, json, yaml, markdown, shell, sql, php, xml, vue, svelte)

### 15.3 JavaScript Köprü Sözleşmesi

**Flutter → Monaco (Flutter `webViewController.evaluateJavascript` çağırır):**

| Fonksiyon | İmza | Açıklama |
|---|---|---|
| `setValue` | `(value: string, language: string)` | İçerik ayarla |
| `getValue` | `(): Promise<string>` | İçerik al |
| `setTheme` | `(theme: "vs-dark" \| "hc-black" \| "vs")` | Tema |
| `setFontSize` | `(n: number)` | Yazı boyutu |
| `setTabSize` | `(n: number)` | Tab boyutu |
| `setWordWrap` | `(b: boolean)` | Word wrap |
| `setMinimap` | `(b: boolean)` | Minimap |
| `setReadOnly` | `(b: boolean)` | Salt-okunur |
| `doFocus` | `()` | Odaklan |
| `goToLine` | `(line: number, col?: number)` | Satıra git |
| `findAndReplace` | `(find: string, replace: string, all: boolean)` | Ara-değiştir |
| `triggerAction` | `(id: string)` | Built-in action (format, comment, vs.) |
| `undo`, `redo` | `()` | Undo/redo |
| `showDiff` | `(original: string, modified: string, language: string)` | Diff moduna geç |

**Monaco → Flutter (`window.flutter_inappwebview.callHandler`):**

| Handler | Argümanlar | Açıklama |
|---|---|---|
| `onReady` | — | Monaco yüklendi, hazır |
| `onChange` | `(value, versionId)` | İçerik değişti (auto-save için) |
| `onSave` | — | Ctrl+S |
| `onCursorMove` | `(line, col)` | İmleç hareket |
| `onSelectionChange` | `(selectedText, line, col, endLine, endCol)` | Seçim değişti |
| `onContextMenu` | `(selectedText, line, col)` | Uzun basma / sağ tık |

### 15.4 Türkçe IME Desteği

- `flutter_inappwebview` ayarları: `ime_mode=true`, `keyboard_display_mode=adjustResize`
- Monaco options: `contextmenu: false` (native menü kullan), `scrollBeyondLastLine: false`
- Test edilmiş: S23 Ultra'da Samsung klavye + Gboard Türkçe ile tam uyumlu

### 15.5 Diff Editor Kullanımı

Sohbet ekranındaki tool diff ve git diff için:
- Aynı WebView, farklı mod
- `showDiff(original, modified, language)` çağrılır
- Monaco `createDiffEditor` ile render
- Side-by-side veya inline seçilebilir

---

## 16. Edge Case'ler ve Çözümleri

| Durum | Çözüm |
|---|---|
| Termux yüklü değil | Kurulum sihirbazı + store linki |
| Termux `allow-external-apps=false` | Sihirbazda adım-adım talimat |
| Go binary yok (ilk kurulum) | Sihirbaz APK assets'inden kopyalar veya indirir |
| Backend ayakta ama cevap yok | 5s timeout, auto-restart denemesi, sonra kurulum moduna dön |
| WebSocket kopuk | Exponential backoff reconnect (500ms → 5s), kaldığı yerden resume |
| AI API key geçersiz oldu | ❌ Kullanılmıyor, API key yok. Bkz. Section 11.0 |
| Claude CLI kurulu değil | Setup sihirbazı otomatik kur önerir, `npm install -g @anthropic-ai/claude-code` arka planda |
| Claude CLI login expired | "Tekrar giriş yap" banner'ı sohbet ekranında, tap → browser OAuth flow |
| Gemini CLI kurulu değil | Aynı şekilde otomatik kur + login akışı |
| CLI login ederken kullanıcı browser'ı kapattı | 5 dakika timeout, sonra "iptal edildi" toast, sihirbaz aynı adımda kalır |
| CLI subprocess crash | Flutter'a `chat.error` push, "Yeniden dene" butonu, crash log kaydedilir |
| CLI output JSON parse hatası | Ham stdout satırını log'a düş, kullanıcıya "beklenmeyen çıktı" göster, CLI versiyonu güncel mi kontrolü öner |
| Kullanıcı aboneliği bitti / rate limit | CLI'dan gelen error event'ini parse et, Flutter'a kullanıcı dostu mesaj göster ("Claude Pro kotanız doldu, abonelik sayfasına git") |
| Tool izni beklerken CLI subprocess timeout oldu | 30 saniye sonra permission dialog otomatik kapanır, CLI restart edilir |
| Dev server crash | Log'da hata vurgula, "AI'a sor" CTA, otomatik yedek |
| Tunnel koptu (cloudflared hata) | Otomatik reconnect 3 kez, sonra notification |
| Disk dolu (< 200MB) | Yedekleme durdurulur, uyarı |
| Pil çok düşük (< %10) | AI sohbet sırasında uyarı, polling aralıkları yavaşlatılır |
| fsnotify event flood | Debounce 200ms, aynı dosya için tek event |
| Büyük dosya editörde açılacak (5MB+) | "Bu dosya büyük, açmak pili zorlayabilir" onay |
| Aynı dosya hem editörde açık hem AI yazdı | "Dosya disk'te değişti, yeniden yükle?" banner |
| İki aynı anda yedek alınmaya çalışılsa | Mutex, ikincisi sessizce iptal |
| Uygulama zorla kapatıldı | Foreground service stick, yeniden açılınca state recover |
| Android 13+ POST_NOTIFICATIONS reddedildi | Kurulum sihirbazında uyar, sonra ayarlardan |
| Yetersiz izin (intent reddedildi) | Kullanıcıya niye gerektiği açıklanır |
| Flutter `flutter run` start'ı uzun sürüyor | Status "starting" kalır, log'da "Flutter run key commands" görülene kadar |
| Claude CLI/Gemini CLI yok | Kullanılmıyor zaten, direkt API |
| Cloudflared yok | "Tunnel kullanabilmek için kurulum" kartı, `pkg install cloudflared` hint |
| Git repo değil, checkpoint isteniyor | Otomatik `git init` yapılır, kullanıcı bilgilendirilir |
| Proje silinme | Önceden zorunlu yedek → onay → sil |
| Uzun AI işi kullanıcı uygulamayı kapattı | Foreground service sayesinde devam eder, bittiğinde bildirim |
| Aynı port kullanımda | `find_free_port` ile otomatik farklı port |
| Termux kapandı (sistem öldürdü) | Boot ekranına dön, tekrar başlat |
| İnternet yok | AI'a gidemez, banner gösterilir, diğer özellikler çalışır |
| Birden fazla telefon aynı server'a bağlanıyor | Desteklenir (LAN IP ile), her istemci ayrı WebSocket |

---

## 17. Performans Hedefleri

| Metrik | Hedef |
|---|---|
| Cold start → Home ekran | < 2s (server hazırsa) |
| Boot screen (server başlatma) | < 5s tipik |
| Dosya ağacı render (500 dosya) | < 250ms |
| Editörde dosya açılış (100KB) | < 700ms |
| Editörde dosya açılış (1MB) | < 2s |
| WebSocket mesaj → UI render | < 50ms |
| Terminal keystroke → render | < 30ms |
| AI ilk token | < 2s (provider'a bağlı) |
| Proje başlatma (dev server up) | Komuta bağlı, ama Flutter: 10-30s |
| Tunnel URL alma | < 5s |
| Yedek alma (50MB proje) | < 10s |
| Git commit | < 2s |
| RAM idle | < 150MB (Flutter) + 30MB (Go) |
| RAM aktif (editor + chat) | < 350MB (Flutter) + 80MB (Go) |
| APK boyutu | < 50MB (Monaco ~15MB dahil) |
| Go binary boyutu | < 25MB |
| Pil tüketimi (1 saat idle arka plan) | < 3% |

---

## 18. Faz-Faz Yol Haritası

Her faz bağımsız çalışır durumda teslim edilir. Bir sonraki faza geçmeden önce öncekinin tüm görevleri tamam olmalı.

### Faz 0 — Temel Hazırlık

- Go proje iskelet (`backend/` dizini, `go.mod`, config, logger, SQLite migration)
- Flutter proje iskelet (`mobile/` dizini, pubspec, theme, router, temel shell)
- Android manifest, Kotlin bridge iskeletleri (TermuxBridge, ServerLifecycleService)
- `assets/monaco/` dağıtımı yerleşir
- Fontlar (`Inter`, `JetBrainsMono`) asset'lere eklenir
- `build_runner` ve `freezed` setup'ı (dosyalar yazılır, kullanıcı üretir)

Çıktı: Uygulama açılır, "Hoş Geldin" ekranı görür ama hiçbir özellik çalışmaz.

### Faz 1 — Kurulum Sihirbazı + Boot + Health

- `/setup` ekranı tam 7 adım
- `TermuxBridge` tam implement (Kotlin)
- `ServerLauncher` — start.sh yaz, intent gönder
- Backend: `/api/setup/*` ve `/api/health` endpoint'leri
- CLI tespit: `/api/setup/cli/detect` + versiyon kontrolü
- CLI login akışı: backend `claude login` ve `gemini auth login` komutlarını PTY ile başlatır, auth URL yakalar, Flutter'a QR + browser deep-link sunar
- Boot ekranı + 30s poll
- Bottom navigation (5 sekme, sadece "Ana" aktif, diğerleri "yakında")

Çıktı: Kullanıcı uygulamayı kuruyor, Claude ve Gemini hesaplarıyla giriş yapıyor (API key yok), ana dashboard'a düşüyor.

### Faz 2 — Proje Yaşam Döngüsü

- Backend: projects API + SQLite kalıcılık + `runner` + fsnotify + env detector
- Flutter: `/projects`, `/projects/new`, `/projects/:id`, `/projects/:id/logs`
- ProjectCard, swipe aksiyonlar, create sheet (3 tab)
- Start/Stop, log tail, pull-to-refresh, polling (3s)
- Tunnel start/stop + QR kod
- WebSocket `events` kanalı — project_status, project_log, tunnel_ready
- Arka plan foreground service + bildirim ("2 proje çalışıyor")

Çıktı: Kullanıcı proje oluşturuyor, başlatıyor, logları izliyor, tunnel açıyor.

### Faz 3 — Dosyalar + Monaco Editör

- Backend: files API, search (grep), fsnotify push, file CRUD
- Flutter: file tree, search, Monaco WebView entegrasyonu
- Quick open palette (Ctrl+P gibi)
- Editor toolbar, keyboard helper row, auto-save
- Dosya sürükle bırak → sohbet context (hazırlık)

Çıktı: Dosya gezer, açar, düzenler, kaydeder. Monaco VS Code benzeri deneyim.

### Faz 4 — Terminal (Gömülü)

- Backend: terminals API, pty.Start, PTY WebSocket stream
- Flutter: xterm.dart, TerminalPage, tab bar, virtual keyboard, cwd seçici
- Multi-tab, resize, copy/paste, ANSI tam
- Persist across reconnect

Çıktı: Tam özellikli terminal. Termux kadar iyi, daha güzel.

### Faz 5 — AI Sohbet (Temel) — **CLI Subprocess Mimarisi**

- Backend: AI service (Claude CLI + Gemini CLI wrapper'ları), session manager, event parser, event translator, permission gate
- CLI tespit: `which claude`, `which gemini`, versiyon kontrolü
- CLI login durumu sürekli polling (her 5 dakikada bir `claude --version` sessiz ping)
- CLI otomatik kurulum worker'ı (`npm install -g ...`, stream log WS'den Flutter'a)
- CLI login akışı (auth URL yakalama, Flutter QR/browser paylaşımı)
- Conversations DB
- WebSocket `chat` kanalı tam implement (Section 6.5.1)
- CLI'dan gelen tool_use event'lerinin permission_gate'e düşmesi
- Flutter: `/chat`, `/chat/:id`, mesaj listesi, user/assistant bubble, tool cards
- ThinkingBar, PermissionDialog, quick actions bar, input bar

Çıktı: Temel sohbet çalışır. Kullanıcı Claude hesabıyla giriş yapar, dosya okuma/yazma tool'larına izin verir, cevap gelir.

### Faz 6 — AI Sohbet (Gelişmiş)

- Context files panel + @mention + slash commands
- Diff viewer (tool önizleme)
- Checkpoint sistemi (otomatik + manuel)
- Hibrit AI mod
- Sesli giriş (SpeechBridge)
- Görsel destek (screenshot, galeri)
- Prompt kütüphanesi (DB + UI)
- Usage dashboard + maliyet izleme + grafik
- Memory (davranışsal)
- Fork to other AI
- Özetle & yeni sohbet

Çıktı: Bölüm 11'deki tüm gelişmiş sohbet özellikleri.

### Faz 7 — Git + Yedekleme

- Backend: git API (go-git) — status, log, diff, commit, branch, pull, push, stash
- Backup service — local ZIP, git checkpoint, retention
- Flutter: `/projects/:id/git` tam panel, diff viewer
- `/backups`, `/backups/:id` — liste, detay, geri yükleme
- AI ile commit mesajı üretimi
- Trigger'lar çalışır durumda

Çıktı: Tam git entegrasyonu + 3 katmanlı yedekleme. AI değişikliklerinden önce otomatik checkpoint.

### Faz 8 — Bildirim Sistemi

- Backend: dispatcher + rules + event kanalı
- Flutter: NotificationBridge tam, `/notifications`
- Kategoriler, kanallar, deep linking
- Sessiz saatler, rate limit
- Action butonları (İzin Ver, Logları Aç, vs.)

Çıktı: Uygulama arka plandayken dahi aktif iletişim.

### Faz 9 — Bulut Yedekleme (Opsiyonel)

- Google Drive OAuth
- Dropbox OAuth
- Upload worker (WiFi check, retry)
- Restore from cloud

Çıktı: İsteyen kullanıcı bulut yedek alabilir.

### Faz 10 — Polish + Ayarlar

- Tüm ayar sayfaları (10 alt sayfa)
- Animasyonlar (animations + staggered)
- Lottie empty state'ler
- Pull-to-refresh her sayfada
- Global error handling
- Haptic feedback stratejik yerlerde
- Dark/AMOLED/System tema
- Font scale
- Keyboard shortcuts (harici klavye desteği)
- Tam Türkçe kontrolü

Çıktı: Cilalanmış, production-hazır uygulama.

---

## 19. Teslim Sırası ve Yapısal Kurallar

### 19.1 Vibe Coder'ın Üretim Sırası

Vibe coder aşağıdaki sırada dosyaları üretir. Her faz kendi içinde bu sırayı izler:

**Backend:**
1. `backend/go.mod` + dependencies listesi
2. `backend/cmd/server/main.go` — entry point
3. `backend/internal/config/` — YAML yükleme, defaults
4. `backend/internal/storage/` — SQLite + migrations
5. `backend/internal/domain/` — iş mantığı paketleri
6. `backend/internal/server/` — Gin setup, middleware
7. `backend/internal/api/` — HTTP handler'lar
8. `backend/internal/ws/` — WebSocket hub
9. `backend/scripts/build.sh` — Termux'ta nasıl derlenir

**Android native:**
1. `android/app/build.gradle` + config
2. `android/app/src/main/AndroidManifest.xml`
3. `android/app/src/main/res/xml/network_security_config.xml`
4. `android/app/src/main/res/values/styles.xml`, `strings.xml`
5. `android/app/src/main/kotlin/com/harun/vibecoding/MainActivity.kt`
6. `android/app/src/main/kotlin/com/harun/vibecoding/TermuxBridge.kt`
7. `android/app/src/main/kotlin/com/harun/vibecoding/ServerLifecycleService.kt`
8. `android/app/src/main/kotlin/com/harun/vibecoding/NotificationHelper.kt`
9. `android/app/src/main/kotlin/com/harun/vibecoding/SpeechBridge.kt`
10. `android/app/src/main/kotlin/com/harun/vibecoding/ScreenshotBridge.kt`

**Flutter (core ilk):**
1. `mobile/pubspec.yaml`
2. `mobile/analysis_options.yaml`
3. `mobile/lib/core/theme/*`
4. `mobile/lib/core/constants/*`
5. `mobile/lib/core/config/*`
6. `mobile/lib/core/network/*`
7. `mobile/lib/core/storage/*`
8. `mobile/lib/core/native/*`
9. `mobile/lib/core/router/*`
10. `mobile/lib/core/widgets/*`
11. `mobile/lib/core/utils/*`

**Flutter (domain sonra):**
12. `mobile/lib/domain/entities/*`
13. `mobile/lib/domain/repositories/*`
14. `mobile/lib/domain/usecases/*`

**Flutter (data):**
15. `mobile/lib/data/models/*`
16. `mobile/lib/data/mappers/*`
17. `mobile/lib/data/repositories_impl/*`

**Flutter (features — fazlara göre):**
18. `mobile/lib/features/setup/*` (Faz 1)
19. `mobile/lib/features/boot/*` (Faz 1)
20. `mobile/lib/features/home/*` (Faz 2)
21. `mobile/lib/features/projects/*` (Faz 2)
22. `mobile/lib/features/files/*` (Faz 3)
23. `mobile/lib/features/terminal/*` (Faz 4)
24. `mobile/lib/features/chat/*` (Faz 5-6)
25. `mobile/lib/features/backup/*` (Faz 7)
26. `mobile/lib/features/notifications/*` (Faz 8)
27. `mobile/lib/features/settings/*` (Faz 10)

**En son:**
28. `mobile/lib/main.dart`
29. `mobile/lib/app.dart`
30. `README.md`

### 19.2 Kod Kalitesi Kuralları

- **Tüm entity'ler Freezed + immutable** — Dart tarafında
- **Tüm DTO'lar `json_serializable` ile** — `.g.dart` üretilir
- **Tüm Go struct'lar JSON tag'leri ile** — camelCase yok, snake_case kullan (Dart da aynı tag'leri bekleyecek)
- **Repository pattern her yerde** — UI asla doğrudan ApiClient'a konuşmaz
- **Magic string yok** — `api_paths.dart`, `ws_types.dart`, `storage_keys.dart`
- **Tüm async hata'lar try/catch** — `AsyncValue.guard` kullan
- **Go tarafı tüm error'lar `%w` ile wrap** — context ekle
- **Log seviyeleri doğru** — debug/info/warn/error
- **Tüm Türkçe string'ler kod içinde hard-coded değil** — bir `l10n/tr.dart` (veya constants) üzerinden
- **Her feature için en az 1 test** — happy path

### 19.3 Güvenlik Notları

- **API key YOK** — Claude ve Gemini oturum bilgileri CLI'ların kendi kontrolünde (`~/.claude/`, `~/.gemini/` altında), Harun Vibe Coding'e sızmaz
- **CLI subprocess komutlarında argüman escape** — kullanıcı input'u CLI argümanına verilirken shell injection'a karşı `exec.Cmd` `Args[]` slice kullanılır, asla string concat ile shell komutu oluşturulmaz
- **SQLite şifreli değil** (kişisel kullanım) — hassas bilgi saklamaz, sadece sohbet geçmişi ve ayarlar
- **Flutter secure storage** — yalnızca yerel cihaz ayarları (örn server token) için kullanılır
- **WebSocket'te authentication** — yerel tek kullanıcı, basit token (config'de otomatik üretilir, Flutter'a secure storage'dan verilir)
- **CORS sadece localhost + LAN** — başka origin reddedilir
- **Path traversal koruması** — `fs_safe.go` tüm file path'leri normalize eder, `..` ve symlink zincirleri reddedilir
- **CLI çıktılarında PII redaction** — log dosyalarına düşerken CLI'nın bastığı URL'lerdeki oturum token'ları maskeli yazılır (`auth=***`)

### 19.4 README.md Beklentisi

Kullanıcıya (kendine) hatırlatıcı olarak `README.md`:

```
# Harun Vibe Coding

Android cihazında AI-destekli mobil IDE.

## Kurulum

1. Termux'u F-Droid'den kur (Play Store versiyonu eski, kullanma)
2. Termux'ta `~/.termux/termux.properties` içine `allow-external-apps=true` ekle
3. Termux'ta temel paketleri kur:
   ```
   pkg update && pkg install -y golang git nodejs cloudflared
   ```
4. Claude Code CLI ve Gemini CLI'ı kur (uygulama da otomatik yapabilir):
   ```
   npm install -g @anthropic-ai/claude-code
   npm install -g @google/gemini-cli
   ```
5. `cd ~/.harun-vibe && ./build.sh` ile Go server'ı derle
6. APK'yı cihaza yükle
7. İlk açılışta sihirbaz seni yönlendirir:
   - Termux kontrolü
   - İzinler
   - Claude ve Gemini **hesabınla giriş** (API key yok, abonelik ile)
   - Tercihler
   - İlk proje

## Sık Sorulanlar

- Termux'ta `allow-external-apps` nasıl etkinleştirilir?
- Claude ve Gemini'ye nasıl giriş yapılır? (CLI login akışı)
- Claude Code CLI veya Gemini CLI kurulu değilse ne olur?
- Sunucu başlamıyor — ne yapmalıyım?

## Geliştirme

Her modül kendi README.md'si ile detaylandırılmıştır.
```

Kısa, pratik. Teknik detay kod içinde zaten var.

---

## 20. Son Notlar

- Bu plan **tek bir vibe coder'ın** takip edebileceği şekilde yazılmıştır
- Her bölüm kendi içinde tam — geri dönüp başka bölüm aramaya gerek yok
- Kararlar **kilitli** — vibe coder kendi kararı vermez, bu plandaki kararları uygular
- Plan ≈ 3500 satır, içinde kritik sözleşmeler (API tablosu, WebSocket mesaj formatı, Android intent extras, Monaco JS köprü, Android bildirim kanalları) bulunur
- Uygulanmayan kısımlar vibe coder'ın inisiyatifinde — kendi en iyi yargısını kullanır, ama plana sadık kalır
- **Yapılmayacak** bölümleri özellikle dikkatli oku — build, signing, pub get, go run komutları yok

### Vizyon — Son Kez

**Harun Vibe Coding, kullanıcının Termux ile hiç etkileşime girmediği, telefonu elinde yatakta yazılım geliştirebildiği, AI ile konuşarak proje inşa ettiği, tek dokunuşla paylaştığı, 3 katmanda yedeklenen, gerçek zamanlı bildirimlerle canlı tutan, bağımsız bir mobil IDE'dir.**

Başlangıç noktası: **Faz 0 → Temel Hazırlık.**

---

*Son güncelleme: Plan finalize edildi. Vibe coder bu plana harfiyen uyarak uygulamayı sıfırdan inşa eder.*
