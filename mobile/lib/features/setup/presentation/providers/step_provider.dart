import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the current wizard step (0..6). Kept local to the setup feature.
class StepController extends Notifier<int> {
  @override
  int build() => 0;
  void next() {
    if (state < 6) state += 1;
  }

  void prev() {
    if (state > 0) state -= 1;
  }

  void goTo(int index) => state = index.clamp(0, 6);
}

final setupStepProvider = NotifierProvider<StepController, int>(StepController.new);
