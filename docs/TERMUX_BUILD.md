# Termux + Android ARM64'te Harun Vibe Coding Derleme Rehberi

Kısa, adım adım. Telefonda Termux + Flutter kurulu varsayılır.

## 0. Gereklilikler (bir kez)

```bash
pkg update -y
pkg install -y git golang nodejs cloudflared openjdk-21 unzip wget
# Flutter yoksa: aynoor/termux-flutter rehberini izle; proxy kurulum gerekli
```

Depoyu klonla:

```bash
cd ~ && git clone https://github.com/hsgsoftware/harun-vibe-coding.git
cd harun-vibe-coding
```

## 1. Backend Go binary

```bash
cd backend
./scripts/build.sh
```

Sonuç: `~/.harun-vibe/harun-vibe-server`. İlk kez için `./scripts/install.sh` çalıştır (config.yaml + start.sh oluşturur).

## 2. Flutter bağımlılıklar + codegen

```bash
cd ~/harun-vibe-coding/mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

> `*.g.dart` / `*.freezed.dart` dosyaları yoksa derleme hata verir. Komut bunları üretir.

## 3. APK (debug, arm64-only)

Kök dizinden tek komut:

```bash
cd ~/harun-vibe-coding
./build_debug.sh
```

İçinde şu komut çalışır:

```
flutter build apk --debug --target-platform android-arm64 --split-per-abi
```

Çıktı: `mobile/build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk`

## 4. Kur + çalıştır

```bash
termux-open mobile/build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk
```

Telefon "bilinmeyen kaynaklardan yüklemeye" izin istediğinde onayla. İlk açılışta kurulum sihirbazı Termux'u + Claude/Gemini CLI'ları kontrol eder.

## Sık karşılaşılan hatalar

| Belirti | Çözüm |
|---|---|
| `OutOfMemoryError` Gradle'dan | `android/gradle.properties` zaten `-Xmx8G` ayarlı; cihazda RAM yetmiyorsa swap aç (`pkg install tsu && sudo zswap`) veya `--no-split-per-abi` çıkar |
| `NDK not found` / `x86 not configured` | Proje zaten `abiFilters "arm64-v8a"` kullanır; eski build klasörünü sil: `cd mobile && flutter clean` |
| `gradle-wrapper-8.14.zip indirilemiyor` | İnternet kontrolü; proxy gerekiyorsa `~/.gradle/gradle.properties` içine `systemProp.http.proxyHost=...` ekle |
| `cloudflared: command not found` | `pkg install cloudflared`; tünel açmak istemiyorsan Setup adımını atlayabilirsin |
| `claude`/`gemini: command not found` | `npm install -g @anthropic-ai/claude-code @google/gemini-cli` ya da Setup sihirbazındaki "Otomatik Kur" butonu |

## Geri dönülen durumlar

- `flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs` — codegen ya da plugin bozulursa ilk dene.
- `rm -rf mobile/android/.gradle mobile/build ~/.gradle/caches/transforms-*` — inatçı Gradle hatalarında.
