import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/curriculum/presentation/pages/home_page.dart';
import '../../features/curriculum/presentation/pages/lesson_page.dart';
import '../../features/curriculum/presentation/pages/free_play_page.dart';
import '../../features/curriculum/domain/entities/curriculum_entities.dart';
import '../../features/progress/presentation/pages/smart_review_page.dart';
import '../../features/progress/presentation/pages/progress_dashboard_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

abstract final class Routes {
  static const home = '/';
  static const lesson = '/lesson';
  static const freePlay = '/free-play';
  static const review = '/review';
  static const progress = '/progress';
  static const settings = '/settings';
}

class LessonRouteArgs {
  const LessonRouteArgs({required this.unit, required this.lesson});
  final WaqtiUnit unit;
  final WaqtiLesson lesson;
}

final appRouterProvider = Provider<GoRouter>((ref) => _buildRouter());

GoRouter _buildRouter() => GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(path: Routes.home, pageBuilder: (ctx, state) => _fade(state, const HomePage())),
    GoRoute(path: Routes.lesson, pageBuilder: (ctx, state) {
      final args = state.extra as LessonRouteArgs;
      return _slide(state, LessonPage(unit: args.unit, lesson: args.lesson));
    }),
    GoRoute(path: Routes.freePlay, pageBuilder: (ctx, state) => _slide(state, FreePlayPage(smartReview: state.extra == true))),
    GoRoute(path: Routes.review, pageBuilder: (ctx, state) => _slide(state, const SmartReviewPage())),
    GoRoute(path: Routes.progress, pageBuilder: (ctx, state) => _slide(state, const ProgressDashboardPage())),
    GoRoute(path: Routes.settings, pageBuilder: (ctx, state) => _slide(state, const SettingsPage())),
  ],
  errorPageBuilder: (ctx, state) => MaterialPage(
    child: Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 64, color: Colors.red),
      const SizedBox(height: 16),
      const Text('صفحة غير موجودة', style: TextStyle(fontFamily: 'Cairo', fontSize: 18)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: () => ctx.go(Routes.home), child: const Text('العودة للرئيسية', style: TextStyle(fontFamily: 'Cairo'))),
    ]))),
  ),
);

CustomTransitionPage<void> _fade(GoRouterState s, Widget child) => CustomTransitionPage(
  key: s.pageKey, child: child,
  transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
  transitionDuration: const Duration(milliseconds: 250),
);

CustomTransitionPage<void> _slide(GoRouterState s, Widget child) => CustomTransitionPage(
  key: s.pageKey, child: child,
  transitionsBuilder: (_, a, __, c) => SlideTransition(
    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeInOutCubic)),
    child: c,
  ),
  transitionDuration: const Duration(milliseconds: 300),
);
