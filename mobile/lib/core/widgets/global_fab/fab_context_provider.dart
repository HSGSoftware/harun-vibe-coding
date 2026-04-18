import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single callable action in the FAB menu. Features override actions by
/// publishing a new list into [FabContextController].
class FabAction {
  const FabAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.enabled = true,
    this.toggled,
    this.onTap,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final bool? toggled; // non-null => rendered as toggle
  final VoidCallback? onTap;
}

/// Categorized override: each feature ships a list of actions per category
/// (nav, actions, status, system) — null means "keep the default".
class FabOverride {
  const FabOverride({this.nav, this.actions, this.status, this.system});
  final List<FabAction>? nav;
  final List<FabAction>? actions;
  final List<FabAction>? status;
  final List<FabAction>? system;
}

class FabContextController extends Notifier<FabOverride> {
  @override
  FabOverride build() => const FabOverride();

  void override(FabOverride o) => state = o;
  void reset() => state = const FabOverride();
}

final fabContextProvider =
    NotifierProvider<FabContextController, FabOverride>(FabContextController.new);
