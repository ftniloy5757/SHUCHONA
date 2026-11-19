import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/tts_stt/voice_service.dart';
import 'package:shuchona/core/widgets/main_shell_scaffold.dart';
import 'package:shuchona/features/admin_dashboard/admin_dashboard_screen.dart';
import 'package:shuchona/features/blood_alert/blood_alert_screen.dart';
import 'package:shuchona/features/craving_sos/craving_sos_modal.dart';
import 'package:shuchona/features/find_care/find_care_screen.dart';
import 'package:shuchona/features/habit_tracker/habit_tracker_screen.dart';
import 'package:shuchona/features/home_dashboard/home_dashboard_screen.dart';
import 'package:shuchona/features/leaderboard/leaderboard_screen.dart';
import 'package:shuchona/features/mental_wellness/mental_wellness_screen.dart';
import 'package:shuchona/features/onboarding_consent/onboarding_screen.dart';
import 'package:shuchona/features/prescribe_safe/prescribe_safe_screen.dart';
import 'package:shuchona/features/voice_chatbot/voice_chatbot_screen.dart';
import 'package:shuchona/features/womens_symptom_guide/womens_symptom_guide_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Notifies GoRouter ONLY when onboarding/auth completion status changes,
/// preventing router recreation when savings, avatar, or Upazila updates occur.
class _AuthRefreshNotifier extends ChangeNotifier {
  void trigger() => notifyListeners();
}

/// Automatically stops active TTS/STT when navigating away from a screen so
/// audio never bleeds across route transitions.
class _VoiceCleanupObserver extends NavigatorObserver {
  _VoiceCleanupObserver(this._ref);

  final Ref _ref;

  void _cleanupVoice() {
    try {
      final voice = _ref.read(voiceControllerProvider);
      if (voice.isSpeaking) {
        _ref.read(voiceControllerProvider.notifier).stopSpeaking();
      }
      if (voice.isListening) {
        _ref.read(voiceControllerProvider.notifier).stopListening();
      }
    } catch (_) {}
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _cleanupVoice();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _cleanupVoice();
  }
}

/// Smooth horizontal slide + fade transition for standard pushed sub-pages.
CustomTransitionPage<void> _slidePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

/// Bottom-up modal sheet slide + fade transition for Voice AI & Craving SOS.
CustomTransitionPage<void> _modalUpPage({
  required GoRouterState state,
  required Widget child,
  bool fullscreenDialog = false,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    fullscreenDialog: fullscreenDialog,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

/// Gentle fade transition for role switches & onboarding completion.
CustomTransitionPage<void> _fadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

/// Wraps secondary bottom-nav tabs so pressing Android Back (including
/// Android 16+ Predictive Back) smoothly returns to `/home` instead of
/// exiting the application immediately.
class _TabBackToHomeGuard extends StatelessWidget {
  const _TabBackToHomeGuard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go('/home');
        }
      },
      child: child,
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier();

  // Only re-evaluate redirects when onboarding completion actually flips.
  ref.listen<bool>(
    userSessionProvider.select((s) => s.isOnboardingComplete),
    (_, _) => refreshNotifier.trigger(),
  );

  final initialComplete = ref.read(userSessionProvider).isOnboardingComplete;

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialComplete ? '/home' : '/onboarding',
    refreshListenable: refreshNotifier,
    observers: [_VoiceCleanupObserver(ref)],
    redirect: (context, state) {
      final complete = ref.read(userSessionProvider).isOnboardingComplete;
      final onOnboarding = state.matchedLocation == '/onboarding';
      if (!complete && !onOnboarding) {
        return '/onboarding';
      }
      if (complete && onOnboarding) {
        return '/home';
      }
      return null;
    },
    routes: [
      // Module 1: Auth + Mandatory Audio-Visual Informed Consent
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const OnboardingScreen()),
      ),

      // Main 4-Tab Shell + Persistent Centered Voice AI Microphone CTA
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prescribe-safe',
                builder: (context, state) =>
                    const _TabBackToHomeGuard(child: PrescribeSafeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/symptoms',
                builder: (context, state) => const _TabBackToHomeGuard(
                  child: WomensSymptomGuideScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/blood',
                builder: (context, state) =>
                    const _TabBackToHomeGuard(child: BloodAlertScreen()),
              ),
            ],
          ),
        ],
      ),

      // Modules 2, 3 & 4: Voice AI Chatbot (launched from centered Mic CTA)
      GoRoute(
        path: '/chatbot',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _modalUpPage(state: state, child: const VoiceChatbotScreen()),
      ),

      // Module 8: Habit Tracker & Streaks
      GoRoute(
        path: '/habits',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const HabitTrackerScreen()),
      ),

      // Module 9: Privacy-Safe Habit Improvement Leaderboard
      GoRoute(
        path: '/leaderboard',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const LeaderboardScreen()),
      ),

      // Module 11: One-Tap Craving & Crisis Support Full-Screen Modal
      GoRoute(
        path: '/craving-sos',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _modalUpPage(
          state: state,
          fullscreenDialog: true,
          child: const CravingSosModal(),
        ),
      ),

      // Modules 12 & 13: Mental Wellness Tips & 7-Day Mood Analytics
      GoRoute(
        path: '/wellness',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const MentalWellnessScreen()),
      ),

      // Modules 14, 15, 16 & 17: Find Care Directory & Smart Voice Reminders
      GoRoute(
        path: '/care',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          final initialTab = tabParam == 'alarms' ? 1 : 0;
          return _slidePage(
            state: state,
            child: FindCareScreen(initialTab: initialTab),
          );
        },
      ),

      // Module 18: Privacy-Preserving NGO / Admin Impact Dashboard
      GoRoute(
        path: '/admin',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const AdminDashboardScreen()),
      ),
    ],
  );

  // Keep adminRoleProvider strictly synchronized with the active route
  // (including Android hardware Back button pops!).
  void syncAdminFlag() {
    final location = router.routerDelegate.currentConfiguration.uri.path;
    final onAdmin = location == '/admin';
    if (ref.read(adminRoleProvider) != onAdmin) {
      Future<void>.microtask(() {
        ref.read(adminRoleProvider.notifier).state = onAdmin;
      });
    }
  }

  router.routerDelegate.addListener(syncAdminFlag);
  ref.onDispose(() {
    router.routerDelegate.removeListener(syncAdminFlag);
    refreshNotifier.dispose();
    router.dispose();
  });

  return router;
});
