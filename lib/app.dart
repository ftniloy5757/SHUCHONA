import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/router/app_router.dart';
import 'package:shuchona/core/theme/app_theme.dart';

class ShuchonaApp extends ConsumerWidget {
  const ShuchonaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isHighContrastDark = ref.watch(highContrastDarkProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'SHUCHONA (সূচনা)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(locale),
      darkTheme: AppTheme.highContrastDark(locale),
      themeMode: isHighContrastDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}

