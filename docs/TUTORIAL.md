# Harun Vibe Coding — git clone'dan APK'ya Uçtan Uca Rehber

Bu rehber sıfırdan başlayıp elinde çalışan bir `app-arm64-v8a-debug.apk` dosyası olana kadar her adımı gösterir. Termux içinde telefonda tamamen yapılabilir.

> **Ön koşul:** Android 10+ cihaz. En az 6 GB RAM önerilir (4 GB'ta swap gerekir). F-Droid'den Termux kurulu.

---

## 1. Termux'u hazırla

Play Store'daki Termux eski; **F-Droid versiyonunu kullan**. Kurulumdan sonra:

```bash
pkg update -y && pkg upgrade -y
termux-setup-storage   # Dosya erişimi izni (resim/proje içe aktarma için)
```

`~/.termux/termux.properties` içine şu satırı ekle:

```
allow-external-apps = true
```

Termux'u **tamamen kapat** (recent apps'ten kaydır) ve yeniden aç. Bu satır olmadan uygulama Termux'a komut yollayamaz.

---

## 2. Gerekli paketleri kur

```bash
pkg install -y git golang nodejs openjdk-21 unzip wget which python cloudflared
```

Sürüm kontrol et:

```bash
go version       # >= 1.22 olmalı
node --version   # >= 18
java -version    # 21
```

---

## 3. Flutter'ı kur (Termux-Flutter)

Termux resmi Flutter'ı desteklemez; topluluk fork'unu kullan:

```bash
cd ~
git clone https://github.com/xffxff/flutter-termux.git flutter
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
flutter --version    # Başarılıysa 3.24+ gösterir
flutter doctor       # Birkaç warning beklenir (android studio yok); aktif kalemler yeşil olmalı
```

> **Not:** `flutter doctor` Android SDK'yı göremezse `pkg install android-tools` ekle, `$ANDROID_HOME` değişkenini Termux'un Android SDK paketinin dizinine koy.

---

## 4. Claude Code + Gemini CLI (opsiyonel, ilk açılışta sihirbaz da yapabilir)

```bash
npm install -g @anthropic-ai/claude-code
npm install -g @google/gemini-cli
claude --version
gemini --version
```

Login uygulamadan yapılacak — şimdi gerekli değil.

---

## 5. Depoyu klonla

```bash
cd ~
git clone https://github.com/hsgsoftware/harun-vibe-coding.git
cd harun-vibe-coding
```

Dizin yapısı:

```
harun-vibe-coding/
├── backend/          # Go sunucu kaynağı
├── mobile/           # Flutter uygulama kaynağı
├── docs/
├── plan.md
├── skill.md
└── build_debug.sh    # Tek komutluk APK derleyici
```

---

## 6. Backend Go binary'sini derle

```bash
cd ~/harun-vibe-coding/backend
./scripts/build.sh
```

Beklenen çıktı:

```
Building -> /data/data/com.termux/files/home/.harun-vibe/harun-vibe-server
Binary size:
-rwxr-xr-x 1 u0_a123 u0_a123 22M harun-vibe-server
```

İlk kurulumda config.yaml + start.sh üret:

```bash
./scripts/install.sh
```

Artık `~/.harun-vibe/` altında:

```
~/.harun-vibe/
├── config.yaml
├── start.sh                   # Termux RunCommand bu dosyayı çağırır
├── harun-vibe-server
├── data.db                    # İlk çalıştırmada oluşur
└── logs/server.log
```

Hızlı test: başka bir Termux sekmesinde çalıştır:

```bash
~/.harun-vibe/start.sh &
curl http://127.0.0.1:8080/api/health
# {"ok":true,"version":"0.1.0",...}
```

Sonra `fg` + `Ctrl+C` ile kapat. Uygulama açıldığında `TermuxBridge` bu sunucuyu otomatik başlatacak.

---

## 7. Flutter bağımlılıkları + kod üretimi

```bash
cd ~/harun-vibe-coding/mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Bu iki komut:
- `pubspec.yaml`'daki 30+ paketi indirir,
- Riverpod `*.g.dart` dosyalarını üretir (provider'lar çalışması için zorunlu),
- Freezed `*.freezed.dart` üretir (entity'ler için).

> **Hata alırsan:** `flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs`

---

## 8. APK derle (debug, arm64-only)

Kök dizine dön ve tek komut çalıştır:

```bash
cd ~/harun-vibe-coding
./build_debug.sh
```

Arka planda şu komut çalışır:

```
flutter build apk --debug --target-platform android-arm64 --split-per-abi
```

**İlk derlemede Gradle 8.14 + bağımlılıklar indiğinden 15-25 dakika sürebilir.** Sonraki derlemeler ~1-3 dk.

Çıktı:

```
mobile/build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk
```

Boyut ~45-70 MB civarı.

---

## 9. APK'yı kur

```bash
termux-open ~/harun-vibe-coding/mobile/build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk
```

Android "bilinmeyen kaynak" uyarısı verirse onay ver. Yükleme bittiğinde uygulama ikonuna dokun.

İlk açılışta otomatik akış:
1. **Boot** ekranı — sunucuyu kontrol eder, yoksa `start.sh`'i Termux'a gönderir.
2. **Setup sihirbazı** — 7 adım (hoş geldin → Termux → izinler → Claude/Gemini login → tercihler → ilk proje → bitti).
3. **Ana dashboard** — aktif projeler + hızlı eylemler + FAB.

---

## 10. Günlük geliştirme döngüsü

Değişiklik yaptığında:

```bash
cd ~/harun-vibe-coding

# 1. Backend değiştiyse
cd backend && ./scripts/build.sh && cd ..

# 2. Flutter kodu değiştiyse (codegen gerekirse)
cd mobile && dart run build_runner build --delete-conflicting-outputs && cd ..

# 3. APK
./build_debug.sh

# 4. Kur
termux-open mobile/build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk
```

Daha hızlı test için hot-reload istiyorsan (cihaz USB debugging ile bağlıyken bilgisayardan):

```bash
cd mobile && flutter run --debug
```

Ama Termux-only akışında APK kurulumu en güvenli yol.

---

## Sık karşılaşılan hatalar

| Belirti | Çözüm |
|---|---|
| `OutOfMemoryError` Gradle'dan | `android/gradle.properties` zaten `-Xmx8G`. 4 GB RAM'li cihazda swap aç: `pkg install tsu && sudo sysctl vm.swappiness=60` veya `--no-split-per-abi` kaldır. |
| `NDK not found` / `x86 required` | `cd mobile && flutter clean`, sonra tekrar `build_debug.sh`. Proje zaten `abiFilters "arm64-v8a"` kullanır. |
| `Could not find gradle-8.14-all.zip` | İnternet kontrolü, proxy varsa `~/.gradle/gradle.properties` içine `systemProp.http.proxyHost=...` ekle. |
| `java: command not found` | `pkg install openjdk-21`; `.bashrc`'ye `export JAVA_HOME=$PREFIX/opt/openjdk` ekle. |
| `cloudflared: command not found` (Tunnel açarken) | `pkg install cloudflared`; tunnel şart değil, atlanabilir. |
| `claude`/`gemini: command not found` (Setup 4. adım) | Setup'taki "Otomatik Kur" butonu ya da `npm install -g @anthropic-ai/claude-code @google/gemini-cli` |
| `SocketException: Connection refused` (Boot ekranı) | `~/.harun-vibe/start.sh` çalıştırıp `curl localhost:8080/api/health`. 200 dönmüyorsa `~/.harun-vibe/logs/server.log`'a bak. |
| `Gradle build too slow / stuck` | `rm -rf ~/.gradle/caches/transforms-* mobile/android/.gradle mobile/build && cd mobile && flutter clean && cd .. && ./build_debug.sh` |
| APK kurarken "App not installed" | Eski sürümü kaldır (`pm uninstall com.harun.vibecoding`) veya imza uyuşmazlığı varsa önce `flutter clean`. |

---

## Özet — 10 komut

```bash
# 1. Termux paketleri
pkg install -y git golang nodejs openjdk-21 unzip wget python cloudflared

# 2. Flutter
git clone https://github.com/xffxff/flutter-termux.git ~/flutter
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

# 3. Depoyu klonla
cd ~ && git clone https://github.com/hsgsoftware/harun-vibe-coding.git
cd harun-vibe-coding

# 4-5. Backend
cd backend && ./scripts/build.sh && ./scripts/install.sh && cd ..

# 6-7. Flutter deps + codegen
cd mobile && flutter pub get && dart run build_runner build --delete-conflicting-outputs && cd ..

# 8. APK
./build_debug.sh

# 9. Kur
termux-open mobile/build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk
```

Bu kadar. Sihirbaz ekranından Claude/Gemini hesabınla giriş yap, ana ekrana geç, "Yeni Proje" butonuyla ilk projeni aç.
