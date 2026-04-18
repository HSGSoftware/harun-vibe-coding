# Harun Vibe Coding

Android cihazında AI-destekli mobil IDE. Flutter ön yüz + Go arka uç, Termux'ta çalışır.
Claude Code CLI ve Gemini CLI subprocess'leri ile AI entegrasyonu — API anahtarı yok.

## Kurulum

1. Termux'u F-Droid'den kur (Play Store versiyonu eskidir, kullanma).
2. Termux'ta `~/.termux/termux.properties` dosyasına ekle: `allow-external-apps = true`.
3. Termux'ta temel paketleri kur:
   ```
   pkg update && pkg install -y golang git nodejs cloudflared
   ```
4. Claude Code CLI ve Gemini CLI'ı kur (uygulama sihirbazı da yapabilir):
   ```
   npm install -g @anthropic-ai/claude-code
   npm install -g @google/gemini-cli
   ```
5. `cd backend && ./scripts/build.sh` ile Go sunucuyu derle. Çıktı
   `~/.harun-vibe/harun-vibe-server` olur.
6. APK'yı cihaza yükle (kişisel build, signing yok).
7. İlk açılışta sihirbaz seni yönlendirir:
   - Termux kontrolü
   - İzinler
   - Claude ve Gemini hesabınla giriş (API anahtarı yok, abonelik ile)
   - Tercihler
   - İlk proje

## Sık Sorulanlar

- **Termux'ta `allow-external-apps` nasıl?** `nano ~/.termux/termux.properties` →
  `allow-external-apps = true` → Ctrl+X → Y → Enter → Termux'u yeniden başlat.
- **AI\'a nasıl giriş yapılır?** Sihirbazın 4. adımında Claude ve Gemini kartlarından
  "Giriş Yap"a bas — backend CLI'ı PTY ile açar, auth URL'i QR/browser olarak
  sana getirir.
- **CLI kurulu değilse?** Setup / Ayarlar > AI altında "Otomatik Kur" butonu
  `npm install -g ...` komutunu Termux'ta çalıştırır; akış logu WS üzerinden UI'a
  düşer.
- **Sunucu başlamıyor — ne yapmalıyım?** Boot ekranı 30 saniye boyunca `/api/health`
  poll eder. Başarısız olursa "Termux'u Aç" butonundan manuel
  `~/.harun-vibe/start.sh` çalıştır.

## Geliştirme

- `backend/` — Go 1.22, tek binary. `cmd/server/main.go` giriş noktası.
  Faz roadmap: plan.md §18.
- `mobile/` — Flutter 3.24, Riverpod 2 + go_router + Freezed. Her feature
  kendi dizini (`features/<name>/presentation`, `/widgets`).
- `mobile/android/` — Kotlin native köprüleri (TermuxBridge, ServerLifecycleService,
  SpeechBridge, ScreenshotBridge). MethodChannel adları plan.md §8.3–8.6'ya sadıktır.
- WebSocket protokolü: `backend/schema/ws-protocol.md`.

**Build komutları Claude tarafından çalıştırılmaz** (skill.md §1.1). Kullanıcı
`build_runner`, `flutter pub get`, `go build` vs. kendi çalıştırır.
