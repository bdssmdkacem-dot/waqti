import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/curriculum/presentation/pages/home_page.dart';
import '../../features/curriculum/presentation/pages/lesson_page.dart';
import '../../features/curriculum/presentation/pages/free_play_page.dart';
import '../../features/curriculum/domain/entities/curriculum_entities.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

part 'app_router.g.dart';

abstract final class Routes {
  static const home     = '/';
  static const lesson   = '/lesson';
  static const freePlay = '/free-play';
  static const settings = '/settings';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) => GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: Routes.home,
      name: 'home',
      pageBuilder: (ctx, state) => _fade(state, const HomePage()),
    ),
    GoRoute(
      path: Routes.lesson,
      name: 'lesson',
      pageBuilder: (ctx, state) {
        final args = state.extra as LessonRouteArgs;
        return _slide(state, LessonPage(unit: args.unit, lesson: args.lesson));
      },
    ),
    GoRoute(
      path: Routes.freePlay,
      name: 'freePlay',
      pageBuilder: (ctx, state) => _slide(state, const FreePlayPage()),
    ),
    GoRoute(
      path: Routes.settings,
      name: 'settings',
      pageBuilder: (ctx, state) => _slide(state, const SettingsPage()),
    ),
  ],
  errorPageBuilder: (ctx, state) => MaterialPage(
    child: Scaffold(
      body: Center(
        child: Text('صفحة غير موجودة', style: TextStyle(fontFamily: 'Cairo')),
      ),
    ),
  ),
);

CustomTransitionPage<void> _fade(GoRouterState s, Widget child) =>
    CustomTransitionPage(
      key: s.pageKey,
      child: child,
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      transitionDuration: const Duration(milliseconds: 250),
    );

CustomTransitionPage<void> _slide(GoRouterState s, Widget child) =>
    CustomTransitionPage(
      key: s.pageKey,
      child: child,
      transitionsBuilder: (_, a, __, c) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: a, curve: Curves.easeInOutCubic)),
        child: c,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );

/// Arguments for the lesson route
class LessonRouteArgs {
  const LessonRouteArgs({required this.unit, required this.lesson});
  final WaqtiUnit unit;
  final WaqtiLesson lesson;
}
