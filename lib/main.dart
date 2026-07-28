import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/ads/data/ad_service.dart';
import 'features/settings/data/sound_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:            Colors.transparent,
    statusBarIconBrightness:   Brightness.light,
    statusBarBrightness:       Brightness.dark,
  ));

  // ── Sound (preloads all 10 audio files) ───────────────────
  await SoundService.instance.initialize();

  // ── AdMob (child-directed, G rating) ──────────────────────
  await AdService.instance.initialize();

  runApp(const ProviderScope(child: WaqtiApp()));
}

class WaqtiApp extends ConsumerWidget {
  const WaqtiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title:                    'وقتي',
      debugShowCheckedModeBanner: false,
      theme:                    WaqtiTheme.theme,
      themeMode:                ThemeMode.light,
      routerConfig:             router,
      // Clamp text scale — prevents layout overflow on accessibility sizes
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(
              mq.textScaler.scale(1).clamp(.85, 1.25),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
