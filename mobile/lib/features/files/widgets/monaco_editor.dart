import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Monaco inside a WebView.
///
/// JS bridge (see plan.md §15.3):
///   Dart -> JS: setContent(content, language), setTheme(name), setReadOnly(bool)
///   JS -> Dart: onChange(value), onSave(), onReady()
class MonacoEditor extends StatefulWidget {
  const MonacoEditor({
    super.key,
    required this.initialContent,
    required this.language,
    required this.onChanged,
    this.onSave,
    this.readOnly = false,
  });

  final String initialContent;
  final String language;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSave;
  final bool readOnly;

  @override
  State<MonacoEditor> createState() => _MonacoEditorState();
}

class _MonacoEditorState extends State<MonacoEditor> {
  InAppWebViewController? _controller;
  bool _ready = false;

  @override
  void didUpdateWidget(covariant MonacoEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ready && _controller != null && widget.initialContent != oldWidget.initialContent) {
      _pushContent();
    }
  }

  Future<void> _pushContent() async {
    final c = _controller;
    if (c == null) return;
    await c.evaluateJavascript(source: '''
      if (window.hvc && window.hvc.setContent) {
        window.hvc.setContent(${_jsEscape(widget.initialContent)}, ${_jsEscape(widget.language)});
        window.hvc.setReadOnly(${widget.readOnly});
      }
    ''');
  }

  String _jsEscape(String s) {
    return '"${s.replaceAll(r'\\', r'\\\\').replaceAll('"', r'\\"').replaceAll('\n', r'\\n').replaceAll('\r', '')}"';
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri('file:///android_asset/flutter_assets/assets/monaco/index.html')),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        supportZoom: false,
        transparentBackground: true,
      ),
      onWebViewCreated: (c) async {
        _controller = c;
        c.addJavaScriptHandler(handlerName: 'onReady', callback: (_) {
          setState(() => _ready = true);
          _pushContent();
          return null;
        });
        c.addJavaScriptHandler(handlerName: 'onChange', callback: (args) {
          if (args.isNotEmpty) widget.onChanged(args.first as String? ?? '');
          return null;
        });
        c.addJavaScriptHandler(handlerName: 'onSave', callback: (_) {
          widget.onSave?.call();
          return null;
        });
      },
    );
  }
}
