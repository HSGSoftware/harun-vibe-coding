import 'package:flutter/material.dart';
import '../../../core/config/build_info.dart';
import '../../../core/l10n/strings_tr.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsAbout)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt, size: 64, color: Color(0xFF5468FF)),
            const SizedBox(height: 12),
            Text(BuildInfo.appName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Sürüm ${BuildInfo.appVersion}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(BuildInfo.packageId, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
