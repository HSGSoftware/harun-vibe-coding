import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/strings_tr.dart';
import '../../../../core/native/termux_bridge.dart';
import '../../widgets/termux_status_card.dart';
import '../../widgets/wizard_shell.dart';
import '../providers/step_provider.dart';

enum _TermuxStep { checking, missing, needsConfig, ready }

class TermuxCheckPage extends ConsumerStatefulWidget {
  const TermuxCheckPage({super.key});

  @override
  ConsumerState<TermuxCheckPage> createState() => _TermuxCheckPageState();
}

class _TermuxCheckPageState extends ConsumerState<TermuxCheckPage> {
  _TermuxStep _step = _TermuxStep.checking;

  @override
  void initState() {
    super.initState();
    _probe();
  }

  Future<void> _probe() async {
    final b = ref.read(termuxBridgeProvider);
    setState(() => _step = _TermuxStep.checking);
    final installed = await b.isInstalled();
    if (!installed) {
      setState(() => _step = _TermuxStep.missing);
      return;
    }
    final configured = await b.isAllowExternalAppsSet();
    setState(() => _step = configured ? _TermuxStep.ready : _TermuxStep.needsConfig);
  }

  @override
  Widget build(BuildContext context) {
    return WizardShell(
      stepIndex: 1,
      totalSteps: 7,
      title: S.setupTermuxTitle,
      nextEnabled: _step == _TermuxStep.ready,
      onBack: ref.read(setupStepProvider.notifier).prev,
      onNext: ref.read(setupStepProvider.notifier).next,
      child: switch (_step) {
        _TermuxStep.checking => const Center(child: CircularProgressIndicator()),
        _TermuxStep.missing => TermuxStatusCard(
            status: TermuxStatus.missing,
            onRetry: _probe,
          ),
        _TermuxStep.needsConfig => TermuxStatusCard(
            status: TermuxStatus.needsConfig,
            onRetry: _probe,
          ),
        _TermuxStep.ready => const TermuxStatusCard(status: TermuxStatus.ready),
      },
    );
  }
}
