# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository State

This repo currently contains **specification only** — no source code has been produced yet:

- `plan.md` (~3200 lines) — the locked, authoritative build spec for the project
- `skill.md` — the vibe-coder operating contract; governs how output is produced

When asked to build/continue the project, treat `plan.md` as the single source of truth and `skill.md` as the operating rules. Do not improvise architectural decisions — they are already fixed.

## Project Identity (plan.md §0)

- **Name / package:** Harun Vibe Coding / `com.harun.vibecoding`
- **What it is:** An AI-first mobile IDE for Android that runs Claude Code CLI and Gemini CLI through a Go backend hosted in Termux, with a Flutter frontend.
- **Stack:** Flutter 3.24+ / Dart 3.5+ · Go 1.22+ (single binary in Termux) · Kotlin native bridges · Monaco in WebView · xterm.dart terminal · SQLite for local persistence
- **Architecture:** Clean architecture + Riverpod 2 (code-gen) + go_router + Freezed on Flutter; Gin + gorilla/websocket + creack/pty + go-git on Go
- **min/target SDK:** 26 / 34 · **Theme:** Material 3, dark-first, accent `#5468ff`
- **UI language:** Turkish. **Code language (identifiers/comments):** English. Never mix.
- **Distribution:** Never published. No Play Store, no signing config, no release workflow.

## Hard Rules — Do Not Violate

From `skill.md` §1 and `plan.md` §0:

1. **Never run these commands.** You produce source files only; the user runs all builds:
   `flutter build|pub get|run|create`, `go build|run|mod tidy|mod init`, `dart run build_runner`, `npm|pnpm install`, any gradle task, `apksigner`, `zipalign`.
2. **Never author generated files** (`*.g.dart`, `*.freezed.dart`). Write the annotated source; the user runs `build_runner`.
3. **AI integration is CLI-subprocess only.** Never import `anthropic-sdk-go`, `google.golang.org/genai`, or any direct AI SDK. Never add API-key fields, inputs, storage, or validation. Claude/Gemini auth happens through `claude login` / `gemini auth login` OAuth flows that the CLI owns — the backend only surfaces the printed auth URL. See `plan.md` §11.0.
4. **No mock / fake / demo / placeholder data.** If backend isn't running, show the setup wizard.
5. **WebView is only for Monaco.** Nothing else may use WebView.
6. **Turkish vs English is strict.** All user-visible strings are Turkish, routed through `mobile/lib/core/l10n/strings_tr.dart` (class `S`) — no scattered string literals. All identifiers, comments, log messages are English.
7. **One phase at a time**, following the order in `plan.md` §18 (Faz 0 → Faz 10) and the per-phase file ordering in `plan.md` §19.1 (Backend → Android native → Flutter core → domain → data → features → `main.dart`/`app.dart` last).
8. **Repository pattern everywhere.** Features never call `Dio()` or `WebSocket.connect()` directly — always through `ApiClient` / `WsClient` → repository.
9. **Path safety.** All Go file operations must go through `internal/util/fs_safe.go`. Subprocess calls use `exec.Cmd.Args []string` — never shell string concatenation.

## Output Layout (plan.md §4.1, §7.1, §19.1)

Produce files in this exact structure:

- `backend/` — Go server (`cmd/server/main.go`, `internal/{config,server,api,ws,domain,storage,notifications,security,util}`, `pkg/`, `schema/`, `scripts/`)
- `mobile/lib/` — Flutter app (`core/`, `domain/{entities,repositories,usecases}/`, `data/{models,mappers,repositories_impl}/`, `features/{setup,boot,home,projects,files,terminal,chat,backup,notifications,settings}/`)
- `mobile/android/app/src/main/kotlin/com/harun/vibecoding/` — Kotlin bridges (`MainActivity`, `TermuxBridge`, `ServerLifecycleService`, `NotificationHelper`, `SpeechBridge`, `ScreenshotBridge`)
- `mobile/assets/` — `monaco/`, `fonts/`, `icons/`, `lottie/`, `translations/`

Config path at runtime: `~/.harun-vibe/config.yaml` (Termux home = `/data/data/com.termux/files/home`).

## Critical Contracts

These sections of `plan.md` define frozen wire/behavior contracts — do not invent alternatives:

- **WebSocket protocol (§6):** `{channel, type, payload, id}` envelope, snake_case keys, required `id` for resume-on-reconnect, 50 ms flush interval for `chat.text` deltas, 1 MB backpressure cap → `chat.error: backpressure_exceeded`. If you need a new message type, update §6 first.
- **Android MethodChannel names and intent extras (§8.3–8.6):** must match the exact string constants both sides.
- **FAB (§7.6):** Global FAB stacked over `MaterialApp.router`, visible on every route except `/setup` and `/boot`, wired via `FabContextProvider`, with drag-and-snap, 4-second idle fade to `alpha 0.25` over 2000 ms, 260 dp menu width, 20 dp corner radius, 24 dp elevation, `0x88000000` backdrop. Do not substitute a vanilla `FloatingActionButton`.
- **CLI permission gate (§11.0, skill §4.4):** tool_use in `--permission-mode plan` → push `chat.permission_request` to Flutter → await `chat.tool_decision` → write `{"type":"permission_response","allow":...}` to CLI stdin.
- **Login flow (skill §4.3):** start `claude login` / `gemini auth login` via PTY, regex the auth URL from stdout, push to Flutter for QR + browser handoff, treat CLI exit 0 as success, verify with `claude --version` or equivalent. Never attempt the OAuth flow in-process.

## Per-File Quality Gates (skill §3.2)

Before finalizing any file, verify:

**Dart:** Freezed + JsonSerializable on models; no magic strings (use `core/constants/*`); `AsyncValue.guard` or typed try/catch on all async; `logger` not `print()`; imports sorted dart → package → relative; no direct `Dio()`/`WebSocket.connect()` outside `core/network`; Riverpod via `@riverpod` code-gen (not manual `StateNotifierProvider`).

**Go:** package comment; errors wrapped with `fmt.Errorf("context: %w", err)`; no `panic()` outside `init`/unrecoverable setup; snake_case JSON tags (Flutter depends on this); `context.Context` as first arg on long-running ops; every goroutine has a defined stop condition; no global mutable state; paths via `util/fs_safe.go`.

**Kotlin:** MethodChannel name matches Flutter exactly; intent extras use the exact §8.3 string constants; lifecycle methods call `super`; coroutines use `lifecycleScope` with an explicit dispatcher; no hardcoded UI strings (use `res/values/strings.xml`).

Prefer many small files over few large ones — split at ~400 lines. One widget per Dart file; one struct + its methods per Go file.

## Execution Discipline

- Follow `plan.md` §19.1 file-production ordering within each phase: Backend → Android native → Flutter core → domain → data → features → `main.dart`/`app.dart` last.
- A phase is "done" when all its files exist, each passes the gates above, and a one-line status is committed. Then continue immediately to the next phase — no ceremony, no confirmation prompts, no deferral sections.
- If the plan is genuinely ambiguous (sections contradict, CLI signature changed, package unavailable, user pushes past a hard rule): stop and ask. Batch clarifications into a single structured list.
- Branch: all development on `claude/init-project-setup-IBYHs` per the session instructions.

## Turkish UX Tone (skill §6)

Route all Turkish strings through `mobile/lib/core/l10n/strings_tr.dart` (`class S`). Imperative action verbs (`Kaydet`, `Başlat`, `Yeniden Dene`), short present-tense status (`Bağlanılıyor…`, `Sunucu çalışıyor`), plain-language errors (`Bağlanamadım. Tekrar deneyelim mi?`). No `Merhaba!`, no `Harika!`, no emojis in prose (emojis only in FAB buttons, quick actions, status icons — inherited from the browser APK and frozen per §7.6).
