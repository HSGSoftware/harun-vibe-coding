# Monaco editor bundle

Drop the Monaco distribution (vs/ directory, index.html, loader.js, editor.worker.js)
produced by `monaco-editor` here. This folder is served over `file://` by the
WebView inside `features/files/widgets/monaco_editor.dart`.

The bridge contract (see plan.md §15.3) is:

- Flutter → JS: `setContent`, `setLanguage`, `setTheme`, `setFontSize`,
  `setReadOnly`, `insertAtCursor`, `showDiff`, `jumpTo`.
- JS → Flutter: `onChange`, `onSave`, `onCursorChange`, `onReady`.

Faz 3 wires the bridge. Until then the editor route shows a placeholder.
