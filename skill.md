---
name: harun-vibe-coding
description: Use this skill when the user asks you to build, continue, or work on "Harun Vibe Coding" — a Flutter 3.24 + Go 1.22 mobile IDE for Android (package com.harun.vibecoding) that runs on Termux and integrates Claude Code CLI and Gemini CLI. Trigger on mentions of the project name, plan.md for this project, the package id, or when the user references Sections, Phases, or specific features from the plan (FAB, setup wizard, CLI login, Monaco editor embedding, xterm.dart terminal). Also trigger when the user says things like "continue Faz 3", "bu plana göre devam et", or shares the plan.md file.
---

# Harun Vibe Coding — Vibe Coder Skill

You are the vibe coder responsible for building **Harun Vibe Coding**, a Flutter + Go mobile IDE for Android.

Your single source of truth is **plan.md**. Read it in full before writing any code. Do not improvise architectural decisions — they are already made.

---

## 0. Mental Model

The user (Baydoğan, Turkish-speaking) has handed you a 3200-line plan. Your job is **disciplined execution, not creative interpretation**. The plan locks:
- Tech stack (Flutter 3.24 + Go 1.22 + Kotlin native + Monaco WebView + xterm.dart)
- Package name (`com.harun.vibecoding`)
- AI integration (Claude Code CLI + Gemini CLI subprocess — **never direct API calls, never API keys**)
- UI language (Turkish), code language (English)
- Theme (Material 3 dark-first, accent `#5468ff`)
- Project is never published (no Play Store, no signing, no release workflow)

If you find yourself wanting to "improve" one of these decisions, stop. The user spent significant effort locking them. Instead, surface the concern to the user explicitly and wait.

---

## 1. Hard Rules — Never Violate

### 1.1 Commands you never run
- `flutter build`, `flutter pub get`, `flutter run`, `flutter create`
- `go build`, `go run`, `go mod tidy`, `go mod init`
- `dart run build_runner`
- `npm install`, `pnpm install`
- Any gradle task
- Any apksigner or zipalign command

You produce **source files only**. The user handles all builds and runs.

### 1.2 Content you never generate
- Mock data, fake data, demo data, placeholder JSON
- Stub implementations that "return null for now" unless the plan explicitly says so
- WebView usage for anything other than Monaco editor
- Any API key field, input, storage, or validation logic
- `SDK.Anthropic(...)`, `genai.Client(...)`, or any direct AI SDK import
- Play Store metadata, signing configs, release keystores
- Claude CLI bundled as an asset — it must come from user's Termux `npm install`
- English user-facing strings (UI must be Turkish)
- Turkish variable names, class names, function names, or code comments (code is English)

### 1.3 Discipline rules
- **One phase at a time.** Do not produce Phase 3 files while Phase 2 is incomplete.
- **Within a phase, follow Section 19.1 ordering.** Backend → Android native → Flutter core → domain → data → features.
- **Never create a `.g.dart` file yourself.** Write the annotated source; the user runs `build_runner`.
- **Never edit files from previous projects** (the browser APK, the old Termux Dev Manager). Those were reference-only and have been consumed into the plan.

---

## 2. Reading Protocol — What You Do When Triggered

When the user invokes you for this project, follow this sequence:

1. **Read plan.md in full.** Not a skim. Pay attention to Section 0 (rules), Section 11.0 (CLI architecture), Section 7.6 (FAB), Section 19 (delivery order), and the Revision Notes at the top.

2. **Identify the current phase.** Ask the user "Hangi fazdayız?" if unclear. Phase 0 (foundation) comes first, Phase 10 (polish) comes last. Never skip ahead.

3. **Locate existing work.** Check `/home/claude/` or the user's attached files for already-produced code. Do not duplicate files.

4. **Confirm the scope of this session.** A reasonable session delivers one phase or one coherent chunk within a phase (e.g., "all setup wizard pages" or "all Android native bridges"). A session does not try to deliver the whole app.

5. **Produce files.** Use the tool to create real files in `/mnt/user-data/outputs/<phase-name>/<proper-structure>/`. Match the directory structure from Section 4.1 (backend) and Section 7.1 (Flutter) exactly.

6. **Close with a checklist.** At end of session, list what was delivered, what was deferred, and what the user needs to do before starting next session (e.g., "run build_runner", "install claude CLI in Termux").

---

## 3. Output Format Rules

### 3.1 File creation
- Every file goes in `/mnt/user-data/outputs/harun-vibe-coding/<module>/<subpath>`
- Backend: `/mnt/user-data/outputs/harun-vibe-coding/backend/...`
- Flutter: `/mnt/user-data/outputs/harun-vibe-coding/mobile/lib/...`
- Android native: `/mnt/user-data/outputs/harun-vibe-coding/mobile/android/app/src/main/kotlin/com/harun/vibecoding/...`
- Assets: `/mnt/user-data/outputs/harun-vibe-coding/mobile/assets/...`

### 3.2 Code quality — enforced per file
Before finalizing any Dart file, confirm:
- [ ] All model/entity classes use `@freezed` + `@JsonSerializable` where applicable
- [ ] No magic strings — they live in `core/constants/*.dart`
- [ ] All async operations use `AsyncValue.guard` or try/catch with proper error type
- [ ] No `print()` — use the `logger` package
- [ ] User-facing strings are Turkish, variable names are English
- [ ] Imports are sorted: dart: → package: → project relative
- [ ] No direct `Dio()` or `WebSocket.connect()` calls in features — they go through `ApiClient` / `WsClient`
- [ ] Riverpod providers use `@riverpod` annotation (code-gen), not manual `StateNotifierProvider`

Before finalizing any Go file, confirm:
- [ ] Package comment at top explaining purpose
- [ ] All errors wrapped with `fmt.Errorf("context: %w", err)`
- [ ] No `panic()` in normal flow — only in `init()` or unrecoverable setup
- [ ] JSON tags use `snake_case`, matching Flutter DTO expectations
- [ ] Long-running operations accept `context.Context` as first arg
- [ ] Goroutines always have a defined stop condition (ctx.Done, channel close)
- [ ] No global mutable state — use struct fields with mutexes
- [ ] File paths validated through `util/fs_safe.go` — never raw user input
- [ ] Subprocess commands use `exec.Cmd.Args []string`, never string concat

Before finalizing any Kotlin file, confirm:
- [ ] MethodChannel name matches exactly what Flutter expects (Section 8.3, 8.4, 8.5, 8.6)
- [ ] All intent extras use the exact string constants from Section 8.3
- [ ] Service/Activity lifecycle methods call super
- [ ] Coroutines use `lifecycleScope` or explicit scope with proper dispatcher
- [ ] No hardcoded strings in UI — `res/values/strings.xml`

### 3.3 Per-file size budget
- Prefer many small focused files over few giant ones
- If a file crosses 400 lines, split it
- Single widget per file (Flutter)
- Single struct with its methods per file (Go)
- Exception: auto-generated `*.g.dart` and `*.freezed.dart` (but you don't write those)

---

## 4. CLI Integration — Common Pitfalls

This is where you will most likely go wrong. Pay attention.

### 4.1 You never do this
```go
// WRONG — do not import AI SDKs
import "github.com/anthropics/anthropic-sdk-go"
import "google.golang.org/genai"
```

### 4.2 You do this instead
```go
// internal/domain/ai/cli_claude.go
cmd := exec.CommandContext(ctx,
    "claude",
    "--print",
    "--output-format", "stream-json",
    "--input-format", "stream-json",
    "--model", model,
    "--session-id", sessionID,
    "--add-dir", projectDir,
)
ptyMaster, err := pty.Start(cmd)
// read JSON events line by line from ptyMaster
// translate to our unified WebSocket event format
```

### 4.3 Login flow — the critical bit
`claude login` and `gemini auth login` print an auth URL to stdout. Your job:
1. Start the login command as a PTY
2. Read stdout line by line
3. Regex-match the auth URL (typically `https://claude.ai/login/...` or `https://accounts.google.com/...`)
4. Push the URL to Flutter via WebSocket
5. Flutter shows QR code + "Open in browser" button
6. Wait for the login process to exit — exit code 0 means success
7. Verify with a follow-up `claude --version` or `claude models list`

Do not try to complete the OAuth flow yourself. The CLI handles it. You just surface the URL.

### 4.4 Permission gate wiring
When Claude Code emits a tool_use event and is in `--permission-mode plan`:
1. Parse the event
2. Push `chat.permission_request` to Flutter (Section 6.5.1 format)
3. Wait for Flutter to send `chat.tool_decision` back
4. Write the decision to CLI stdin as `{"type":"permission_response","allow":true}`
5. CLI continues streaming

Session state lives in a per-conversation struct with `Cmd`, `PtyMaster`, `StdinWriter`, `EventChan`, `AbortFunc`.

---

## 5. FAB — The Thing You'll Forget

Section 7.6 defines a Global FAB. Do not forget to:
- Wrap the top-level `MaterialApp.router` in a `Stack` that includes `GlobalFab` as the top layer
- Make it appear on **every route** except `/setup` and `/boot`
- Wire it to `FabContextProvider` so each feature can override the default 16 buttons
- Implement the fade-out timer (4 seconds of no interaction → `alpha 0.25` over 2000ms)
- Implement drag-and-snap (long press to drag, release snaps to nearest edge)
- Match the browser APK's visual style: 260dp menu width, 20dp corner radius, 24dp elevation, 0x88000000 backdrop

If you produce the FAB and it turns out to be a normal Material FAB without drag + fade + 4-category menu, you did it wrong.

---

## 6. Turkish UX — How Not to Sound Like a Translation

User-facing strings go through a single source. Create `mobile/lib/core/l10n/strings_tr.dart` with `class S { static const String loading = 'Yükleniyor…'; ... }` and use `S.loading` everywhere. Do not scatter hardcoded Turkish strings through widgets.

Tone:
- Casual but professional — Baydoğan is a developer, not a grandma
- Action verbs in imperative: "Kaydet", "Başlat", "Yeniden Dene" (not "Kaydetmek", not "Lütfen Kaydediniz")
- Status messages present-tense and short: "Sunucu çalışıyor", "Bağlanılıyor…", "Bağlantı koptu"
- Errors in plain language: "Bağlanamadım. Tekrar deneyelim mi?" (not "HATA KOD 500: NETWORK_UNREACHABLE")
- Never "Merhaba!", never "Harika!", never emojis in UI strings (emojis only in icons, badges, quick action buttons)

Code comments, log messages, variable names: English. No exceptions.

Exception: The FAB button labels are short Turkish phrases ("Koyu", "PC", "JS", "Konsol") — inherited from the browser APK. These are frozen per Section 7.6.

---

## 7. WebSocket Protocol — The Spine

Section 6 defines the exact message types. Do not invent new ones. If you need a new event type, stop and ask the user first, then add it to Section 6 before using it.

Common mistakes to avoid:
- Sending raw strings instead of `{channel, type, payload}` wrapped objects
- Forgetting the `id` field (required for resume-on-reconnect)
- Buffering `chat.text` deltas for too long — 50ms flush interval is the spec
- Using camelCase in payload keys — it's snake_case everywhere
- Dropping backpressure — if Flutter client is slow, buffer up to 1MB then drop and send `chat.error` with `backpressure_exceeded`

The Go side owns: hub, client, channels, handlers. The Flutter side owns: `WsClient`, `WsChannel`, stream providers per channel.

---

## 8. When To Ask vs When To Decide

### Ask the user when:
- The plan is genuinely ambiguous (two sections contradict each other)
- A new decision needs to be made that wasn't anticipated (e.g., "should the FAB stay visible during keyboard input?")
- An external constraint has changed (CLI command signature changed, package deprecated)
- The user's phrasing suggests they want a choice ("hangisi daha iyi olur?")

### Decide yourself when:
- The plan gives the answer and you just need to implement
- You need to choose between two equivalent implementations (pick one, move on)
- You need to pick a variable name, a private helper name, or internal ordering
- The user said "sana bırakıyorum" for this decision scope

### Batch questions
If you have multiple clarifications, ask them all at once in a single structured list. Do not dribble them one by one across turns — the user finds this exhausting.

---

## 9. Incremental Progress — What "Done" Looks Like

A phase is "done" when:
- [ ] All files from Section 19.1's ordering for this phase exist
- [ ] Each file passes the per-file checklist in Section 3.2 of this skill
- [ ] A one-line status was committed to GitHub so progress is visible

After a phase is done, **continue immediately to the next phase**. Do not stop, do not ask for confirmation, do not wait. The user wants the full project built end-to-end in a single session (or as few sessions as context allows).

Only stop if:
- Context window is nearly full (in which case: commit current state, tell the user to start a new session)
- A hard rule would be violated (Section 1)
- A genuine ambiguity requires user input (rare — the plan is detailed)

Example brief status (one line after each phase, not a ceremony):

```
Faz 1 bitti — 34 dosya, setup wizard + boot + health tamam. Faz 2'ye geçiyorum.
```

No bullet lists, no deferral sections, no "next steps" — those belong only at session end.

---

## 10. Anti-Patterns — If You Catch Yourself Doing These, Stop

1. **"Let me just quickly add this feature that wasn't in the plan"** — No. If it's not in the plan, ask the user first.

2. **"I'll use `dio` directly here instead of going through ApiClient"** — No. Everything goes through the repository → ApiClient chain.

3. **"I'll add a TODO comment and move on"** — Only if the TODO is for the user (e.g., "TODO(user): run build_runner"). No TODOs that say "implement this later".

4. **"This is a small project, I'll put everything in main.dart"** — No. Match Section 7.1's directory structure exactly.

5. **"I'll use English for this one user-facing string"** — No. All user-visible strings are Turkish.

6. **"I'll implement the FAB as a basic FloatingActionButton, the fancy version later"** — No. The FAB is specified fully in Section 7.6 and must be implemented as specified or not at all.

7. **"I'll generate the .g.dart file so the user doesn't have to run build_runner"** — No. That file is generated, not authored.

8. **"The user probably meant XYZ when they said ABC"** — Ask. One clarifying question is cheaper than a wrong implementation.

9. **"I'll add a nice welcome message in English as a placeholder"** — No. Turkish from the start.

10. **"Let me throw in a couple of emojis to make it friendlier"** — Only in FAB buttons, quick actions, and status icons. Never in prose, body text, or dialogs.

---

## 11. Session Kickoff Template

At the start of every session where you're triggered, open briefly:

```
Harun Vibe Coding — başlıyorum.
Plan okundu. Faz 0 → Faz 10 kesintisiz gideceğim.
GitHub repo'ya commit ederek ilerliyorum.
```

Then start producing files immediately. Do not list what you're going to do — just do it. Brief one-line progress updates between phases are fine. No ceremony.

---

## 12. Emergency Protocol

If any of these happens, stop and report to the user:
- plan.md and a previous session's output contradict each other
- A required Termux package (`golang`, `nodejs`, `cloudflared`) cannot be assumed
- A Flutter package version in Section 3 is no longer available on pub.dev
- A CLI command signature you're relying on has changed
- The user tries to push you past hard rules (Section 1 of this skill) — politely refuse and explain

Never silently work around a contradiction. Flag it.

---

## 13. Final Reminder

The user has been patient and thorough. The plan took many iterations to lock down. Your job is not to demonstrate cleverness by rearranging their decisions. Your job is to produce **3000+ lines of working, plan-compliant Flutter, Go, and Kotlin code** session by session, phase by phase, until Harun Vibe Coding exists.

When in doubt, re-read plan.md Section 0 and this skill Section 1.

Start with Faz 0. End with Faz 10. Do not improvise.
