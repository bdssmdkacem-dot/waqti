import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/curriculum/domain/entities/curriculum_entities.dart';
import '../../features/curriculum/presentation/pages/free_play_page.dart';
import '../../features/curriculum/presentation/pages/home_page.dart';
import '../../features/curriculum/presentation/pages/lesson_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

// ── Route paths ───────────────────────────────────────────────
abstract final class Routes {
  static const home = '/';
  static const lesson = '/lesson';
  static const freePlay = '/free-play';
  static const settings = '/settings';
}

// ── Route args ────────────────────────────────────────────────
class LessonRouteArgs {
  const LessonRouteArgs({
    required this.unit,
    required this.lesson,
  });

  final WaqtiUnit unit;
  final WaqtiLesson lesson;
}

// ── Manual provider (no riverpod_generator) ───────────────────
final appRouterProvider = Provider<GoRouter>((ref) => _buildRouter());

GoRouter _buildRouter() => GoRouter(
      initialLocation: Routes.home,
      debugLogDiagnostics: false,
      routes: [
        GoRoute(
          path: Routes.home,
          pageBuilder: (ctx, state) => _fade(
            state,
            const HomePage(),
          ),
        ),
        GoRoute(
          path: Routes.lesson,
          pageBuilder: (ctx, state) {
            final args = state.extra as LessonRouteArgs;

            return _slide(
              state,
              LessonPage(
                unit: args.unit,
                lesson: args.lesson,
              ),
            );
          },
        ),
        GoRoute(
          path: Routes.freePlay,
          pageBuilder: (ctx, state) => _slide(
            state,
            const FreePlayPage(),
          ),
        ),
        GoRoute(
          path: Routes.settings,
          pageBuilder: (ctx, state) => _slide(
            state,
            const SettingsPage(),
          ),
        ),
      ],
      errorPageBuilder: (ctx, state) => MaterialPage(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'صفحة غير موجودة',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ctx.go(Routes.home),
                  child: Text(
                    'العودة للرئيسية',
                    style: GoogleFonts.cairo(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

CustomTransitionPage<void> _fade(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _slide(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
        ),
        child: child,
      );
    },
  );
}
