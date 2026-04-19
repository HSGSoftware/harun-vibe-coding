import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/route_paths.dart';
import '../../theme/color_schemes.dart';
import '../../utils/haptics.dart';
import 'fab_controller.dart';
import 'fab_menu_overlay.dart';
import 'fab_position_manager.dart';

/// Global floating action button mounted in app.dart's overlay stack.
/// Visible on every route except [RoutePaths.setup] and [RoutePaths.boot].
class GlobalFab extends ConsumerStatefulWidget {
  const GlobalFab({super.key});

  @override
  ConsumerState<GlobalFab> createState() => _GlobalFabState();
}

class _GlobalFabState extends ConsumerState<GlobalFab> with SingleTickerProviderStateMixin {
  static const double _size = 56;
  static const Duration _fadeDelay = Duration(seconds: 4);
  static const Duration _fadeDuration = Duration(milliseconds: 2000);

  Timer? _idleTimer;
  bool _faded = false;

  @override
  void initState() {
    super.initState();
    _scheduleFade();
  }

  void _scheduleFade() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_fadeDelay, () => setState(() => _faded = true));
  }

  void _resetFade() {
    if (_faded) setState(() => _faded = false);
    _scheduleFade();
  }

  bool _shouldHide(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    return location == RoutePaths.setup || location == RoutePaths.boot;
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldHide(context)) return const SizedBox.shrink();

    final Size screen = MediaQuery.of(context).size;
    final FabPosition pos = ref.watch(fabPositionProvider);
    final FabState fab = ref.watch(fabControllerProvider);

    return Stack(
      children: [
        if (fab.open)
          FabMenuOverlay(
            onClose: () => ref.read(fabControllerProvider.notifier).close(),
            origin: Offset(screen.width - pos.dx, screen.height - pos.dy),
          ),
        Positioned(
          right: pos.dx,
          bottom: pos.dy,
          child: GestureDetector(
            onTap: () async {
              await Haptics.select();
              _resetFade();
              ref.read(fabControllerProvider.notifier).toggle();
            },
            onLongPressStart: (_) {
              Haptics.medium();
              ref.read(fabControllerProvider.notifier).setDragging(true);
              _resetFade();
            },
            onLongPressMoveUpdate: (details) {
              ref.read(fabPositionProvider.notifier).moveBy(details.offsetFromOrigin);
            },
            onLongPressEnd: (_) {
              Haptics.light();
              ref.read(fabPositionProvider.notifier).snapToEdge(screen, fabSize: _size);
              ref.read(fabControllerProvider.notifier).setDragging(false);
            },
            child: AnimatedOpacity(
              opacity: (_faded && !fab.open) ? 0.25 : 1,
              duration: _fadeDuration,
              curve: Curves.easeOut,
              child: Container(
                width: _size,
                height: _size,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x555468FF), blurRadius: 18, offset: Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
