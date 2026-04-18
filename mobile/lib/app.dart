import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/dynamic_theme.dart';
import 'core/widgets/global_fab/global_fab.dart';

class HarunVibeCodingApp extends ConsumerWidget {
  const HarunVibeCodingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    final ThemeSelection theme = ref.watch(themeControllerProvider);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return MaterialApp.router(
      title: 'Harun Vibe Coding',
      debugShowCheckedModeBanner: false,
      theme: theme.buildLightVariant(),
      darkTheme: theme.buildDarkVariant(),
      themeMode: theme.materialThemeMode,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const Positioned.fill(child: IgnorePointer(ignoring: false, child: _FabLayer())),
          ],
        );
      },
    );
  }
}

class _FabLayer extends StatelessWidget {
  const _FabLayer();

  @override
  Widget build(BuildContext context) {
    return const Align(alignment: Alignment.bottomRight, child: GlobalFab());
  }
}
