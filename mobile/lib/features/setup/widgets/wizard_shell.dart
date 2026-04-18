import 'package:flutter/material.dart';

import '../../../core/l10n/strings_tr.dart';
import 'step_indicator.dart';

class WizardShell extends StatelessWidget {
  const WizardShell({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.title,
    required this.child,
    required this.onNext,
    this.onBack,
    this.nextLabel = S.next,
    this.nextEnabled = true,
  });

  final int stepIndex;
  final int totalSteps;
  final String title;
  final Widget child;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final String nextLabel;
  final bool nextEnabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(child: StepIndicator(count: totalSteps, current: stepIndex)),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
              ),
              const SizedBox(height: 16),
              Expanded(child: child),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: nextEnabled ? onNext : null,
                      child: Text(nextLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
