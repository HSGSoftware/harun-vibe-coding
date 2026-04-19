import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Open/closed + "currently dragging" state for the global FAB.
class FabState {
  const FabState({this.open = false, this.dragging = false});
  final bool open;
  final bool dragging;

  FabState copyWith({bool? open, bool? dragging}) =>
      FabState(open: open ?? this.open, dragging: dragging ?? this.dragging);
}

class FabController extends Notifier<FabState> {
  @override
  FabState build() => const FabState();

  void toggle() => state = state.copyWith(open: !state.open);
  void open() => state = state.copyWith(open: true);
  void close() => state = state.copyWith(open: false);
  void setDragging(bool dragging) => state = state.copyWith(dragging: dragging);
}

final fabControllerProvider = NotifierProvider<FabController, FabState>(FabController.new);
