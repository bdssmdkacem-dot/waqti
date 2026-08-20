import 'dart:async';

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
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  // Do not block the first frame on audio/AdMob initialization.
  // A failed optional service must never prevent Waqti from opening.
  runApp(const ProviderScope(child: WaqtiApp()));

  unawaited(_initializeServices());
}

Future<void> _initializeServices() async {
  try {
    await SoundService.instance.initialize();
  } catch (e) {
    debugPrint('SoundService initialization failed: $e');
  }

  try {
    await AdService.instance.initialize();
  } catch (e) {
    debugPrint('AdService initialization failed: $e');
  }
}

class WaqtiApp extends ConsumerWidget {
  const WaqtiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'وقتي',
      debugShowCheckedModeBanner: false,
      theme: WaqtiTheme.theme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      // Clamp text scale — prevents layout overflow on accessibility sizes.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(
              mq.textScaler.scale(1).clamp(.85, 1.25),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
