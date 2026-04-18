import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/l10n/strings_tr.dart';
import '../../widgets/permission_request_card.dart';
import '../../widgets/wizard_shell.dart';
import '../providers/step_provider.dart';

class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({super.key});

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage> {
  final Map<String, bool> _granted = {};

  Future<void> _request(Permission perm, String key) async {
    final res = await perm.request();
    setState(() => _granted[key] = res.isGranted);
  }

  @override
  Widget build(BuildContext context) {
    return WizardShell(
      stepIndex: 2,
      totalSteps: 7,
      title: S.setupPermissionsTitle,
      onBack: ref.read(setupStepProvider.notifier).prev,
      onNext: ref.read(setupStepProvider.notifier).next,
      child: ListView(
        children: [
          PermissionRequestCard(
            icon: Icons.notifications_active,
            title: 'Bildirimler',
            body: 'AI cevapları, sunucu hataları ve yedekleme bildirimleri için.',
            granted: _granted['notifications'] == true,
            onRequest: () => _request(Permission.notification, 'notifications'),
          ),
          const SizedBox(height: 12),
          PermissionRequestCard(
            icon: Icons.mic,
            title: 'Mikrofon',
            body: 'Sohbete sesli mesaj göndermek için (opsiyonel).',
            granted: _granted['microphone'] == true,
            onRequest: () => _request(Permission.microphone, 'microphone'),
          ),
          const SizedBox(height: 12),
          PermissionRequestCard(
            icon: Icons.photo_library,
            title: 'Galeri / Kamera',
            body: 'Sohbete ekran görüntüsü veya resim eklemek için (opsiyonel).',
            granted: _granted['media'] == true,
            onRequest: () => _request(Permission.photos, 'media'),
          ),
          const SizedBox(height: 12),
          PermissionRequestCard(
            icon: Icons.battery_charging_full,
            title: 'Pil optimizasyonu muafiyeti',
            body: 'Arka planda da çalışmaya devam etmesi için (opsiyonel).',
            granted: _granted['battery'] == true,
            onRequest: () => _request(Permission.ignoreBatteryOptimizations, 'battery'),
          ),
        ],
      ),
    );
  }
}
