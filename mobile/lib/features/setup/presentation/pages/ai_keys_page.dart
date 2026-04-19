import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/strings_tr.dart';
import '../../../../core/utils/clipboard.dart';
import '../../../../domain/entities/cli_status.dart';
import '../../widgets/wizard_shell.dart';
import '../providers/setup_controller.dart';
import '../providers/step_provider.dart';

class AiKeysPage extends ConsumerWidget {
  const AiKeysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SetupData> async = ref.watch(setupControllerProvider);
    final SetupController ctrl = ref.read(setupControllerProvider.notifier);
    final data = async.valueOrNull ?? const SetupData();
    final claude = data.detection?.claude;
    final gemini = data.detection?.gemini;
    final bool canProceed = (claude?.state == CliState.ready) || (gemini?.state == CliState.ready);

    return WizardShell(
      stepIndex: 3,
      totalSteps: 7,
      title: S.setupAiTitle,
      onBack: ref.read(setupStepProvider.notifier).prev,
      onNext: ref.read(setupStepProvider.notifier).next,
      nextEnabled: canProceed,
      child: ListView(
        children: [
          Text(S.setupAiSubtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          _ProviderCard(
            title: S.setupAiClaudeTitle,
            subtitle: S.setupAiClaudeSubtitle,
            status: claude,
            log: data.cliLog,
            authUrl: data.authUrl,
            onInstall: () => ctrl.installCli('claude'),
            onLogin: () => ctrl.loginCli('claude'),
            onLogout: () => ctrl.logoutCli('claude'),
            onTest: () => ctrl.testCli('claude'),
          ),
          const SizedBox(height: 16),
          _ProviderCard(
            title: S.setupAiGeminiTitle,
            subtitle: 'Google hesabınla giriş yap.',
            status: gemini,
            log: data.cliLog,
            authUrl: data.authUrl,
            onInstall: () => ctrl.installCli('gemini'),
            onLogin: () => ctrl.loginCli('gemini'),
            onLogout: () => ctrl.logoutCli('gemini'),
            onTest: () => ctrl.testCli('gemini'),
          ),
          const SizedBox(height: 24),
          Text(
            'CLI\'lar oturum bilgilerini kendi yollarında saklar (~/.claude, ~/.gemini). Harun Vibe Coding bu bilgilere dokunmaz.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.log,
    required this.authUrl,
    required this.onInstall,
    required this.onLogin,
    required this.onLogout,
    required this.onTest,
  });

  final String title;
  final String subtitle;
  final CliStatus? status;
  final List<String> log;
  final String? authUrl;
  final VoidCallback onInstall;
  final VoidCallback onLogin;
  final VoidCallback onLogout;
  final Future<bool> Function() onTest;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = status?.state ?? CliState.notInstalled;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          _strip(context, state),
          const SizedBox(height: 12),
          switch (state) {
            CliState.notInstalled => FilledButton.icon(
                onPressed: onInstall,
                icon: const Icon(Icons.download),
                label: const Text(S.setupAiInstall),
              ),
            CliState.loggedOut => FilledButton.icon(
                onPressed: onLogin,
                icon: const Icon(Icons.login),
                label: const Text(S.setupAiLogin),
              ),
            CliState.ready => Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      final ok = await onTest();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'Test başarılı' : 'Test başarısız')),
                      );
                    },
                    child: const Text(S.setupAiTest),
                  ),
                  TextButton(onPressed: onLogout, child: const Text(S.setupAiLogout)),
                ],
              ),
          },
          if (authUrl != null && state == CliState.loggedOut) ...[
            const SizedBox(height: 16),
            _AuthUrlPanel(url: authUrl!),
          ],
          if (log.isNotEmpty) ...[
            const SizedBox(height: 16),
            _LogPanel(log: log),
          ],
        ],
      ),
    );
  }

  Widget _strip(BuildContext context, CliState state) {
    final (Color c, String label) = switch (state) {
      CliState.notInstalled => (const Color(0xFFEF4444), 'CLI kurulu değil'),
      CliState.loggedOut => (const Color(0xFFF59E0B), 'Giriş yapılmadı'),
      CliState.ready => (const Color(0xFF22C55E), 'Bağlı'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _AuthUrlPanel extends StatelessWidget {
  const _AuthUrlPanel({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          QrImageView(data: url, size: 140, backgroundColor: Colors.white),
          const SizedBox(height: 10),
          SelectableText(url, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => ClipboardX.copy(url),
                icon: const Icon(Icons.copy),
                label: const Text('Kopyala'),
              ),
              FilledButton.icon(
                onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Tarayıcıda Aç'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LogPanel extends StatelessWidget {
  const _LogPanel({required this.log});
  final List<String> log;

  @override
  Widget build(BuildContext context) {
    final slice = log.length > 8 ? log.sublist(log.length - 8) : log;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(maxHeight: 140),
      child: SingleChildScrollView(
        child: Text(
          slice.join('\n'),
          style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: Colors.white70),
        ),
      ),
    );
  }
}
