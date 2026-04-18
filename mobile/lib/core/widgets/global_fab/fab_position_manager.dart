import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the current on-screen offset of the FAB and snaps to the nearest
/// vertical edge on drag release. Values are persisted by a Faz 10 provider.
class FabPosition {
  const FabPosition({this.dx = 16, this.dy = 120});
  final double dx;
  final double dy;
  FabPosition copyWith({double? dx, double? dy}) => FabPosition(dx: dx ?? this.dx, dy: dy ?? this.dy);
}

class FabPositionController extends Notifier<FabPosition> {
  @override
  FabPosition build() => const FabPosition();

  void moveBy(Offset delta) {
    state = state.copyWith(dx: state.dx - delta.dx, dy: state.dy - delta.dy);
  }

  void snapToEdge(Size screen, {double margin = 16, double fabSize = 56}) {
    final double maxX = screen.width - fabSize - margin;
    final bool snapRight = (state.dx < (screen.width - fabSize) / 2);
    final double targetX = snapRight ? margin : maxX;
    final double minY = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).padding.top + 16;
    final double maxY = screen.height - fabSize - 120;
    final double clampedY = state.dy.clamp(minY, maxY);
    state = state.copyWith(dx: screen.width - fabSize - targetX, dy: clampedY);
  }
}

final fabPositionProvider =
    NotifierProvider<FabPositionController, FabPosition>(FabPositionController.new);
