// lib/shared/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_controller.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_role_screen.dart';
import '../../features/auth/screens/register_expert_screen.dart';
import '../../features/auth/screens/register_seeker_screen.dart';
import '../../features/auth/screens/pending_verification_screen.dart';
import '../../features/auth/screens/suspended_screen.dart';
import '../../features/admin/screens/admin_mediation_screen.dart';
import '../../features/admin/screens/admin_verification_screen.dart';
import '../../features/admin/screens/admin_nav_screen.dart';
import '../../features/wallet/screens/wallet_dashboard_screen.dart';
import '../../features/wallet/screens/withdraw_request_screen.dart';
import '../../features/expert/screens/expert_nav_screen.dart';
import '../../features/expert/screens/expert_dashboard_screen.dart';
import '../../features/seeker/screens/seeker_nav_screen.dart';
import '../../features/seeker/screens/seeker_dashboard_screen.dart';
import '../../features/profile/screens/expert_profile_view.dart';
import '../../features/quest/screens/expert_quest_feed_screen.dart';
import '../../features/quest/screens/quest_tracking_view.dart';
import '../../features/quest/screens/quest_detail_view.dart';
import '../../features/payment/screens/payment_view.dart';
import '../../features/seeker/screens/seeker_quest_applicants_screen.dart';
import '../../features/rating/screens/rating_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../core/constants/app_enums.dart';
import '../../features/seeker/screens/seeker_post_quest_screen.dart';
import '../../features/seeker/screens/seeker_find_expert_screen.dart';
import '../../features/seeker/screens/seeker_settings_screen.dart';
import '../../features/notification/screens/notification_screen.dart';
import '../../features/expert/screens/expert_profile_menu_screen.dart';
import '../../features/expert/screens/expert_orders_screen.dart';
import '../../features/seeker/screens/seeker_orders_screen.dart';

// ─── Route Names ─────────────────────────────────────────────────────────────
abstract class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String registerRole = '/register/role';
  static const String registerExpert = '/register/expert';
  static const String registerSeeker = '/register/seeker';
  static const String pendingVerification = '/pending-verification';
  static const String otpVerification = '/otp';
  static const String suspended = '/suspended';

  static const String expertDashboard = '/expert/dashboard';
  static const String expertProfile = '/expert/profile';
  static const String expertEditProfile = '/expert/profile/edit';
  static const String expertQuestFeed = '/expert/quests';
  static const String expertQuestDetail = '/expert/quests/:questId';
  static const String expertApplyQuest = '/expert/quests/:questId/apply';
  static const String expertActiveQuest = '/expert/active-quest/:questId';
  static const String expertSubmitWork = '/expert/submit/:questId';
  static const String expertRank = '/expert/rank';
  static const String expertWalletDashboard = '/expert/wallet';
  static const String expertWithdraw = '/expert/wallet/withdraw';
  static const String expertBoost = '/expert/boost';
  static const String expertOrders = '/expert/orders';
  static const String expertNotifications = '/expert/notifications';

  static const String seekerDashboard = '/seeker/dashboard';
  static const String seekerFastSearch = '/seeker/search';
  static const String seekerExpertProfile = '/seeker/expert/:expertId';
  static const String seekerPostQuest = '/seeker/post-quest';
  static const String seekerQuestApplicants =
      '/seeker/quests/:questId/applicants';
  static const String seekerActiveQuest = '/seeker/active-quest/:questId';
  static const String seekerReviewSubmission = '/seeker/review/:questId';
  static const String seekerRating = '/seeker/rating/:questId';
  static const String seekerOrders = '/seeker/orders';
  static const String seekerNotifications = '/seeker/notifications';

  static const String adminMediation = '/admin/mediation';
  static const String adminVerification = '/admin/verification';
  static const String adminHome = '/admin/home';

  static const String payment = '/payment/:questId';
  static const String paymentSuccess = '/payment-success';
  static const String dispute = '/dispute/:questId';
  static const String chat = '/chat/:chatId';
  static const String settings = '/settings';
  static const String faq = '/faq';
  static const String barterQuest = '/barter/:questId';
}

// ─── Router Provider ──────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  // Mock MVP: userProvider is the single source of truth (no Firebase)
  final userState = ref.watch(userProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final loc = state.matchedLocation;

      final isAuthScreen = loc == AppRoutes.login ||
          loc == AppRoutes.registerRole ||
          loc == AppRoutes.registerExpert ||
          loc == AppRoutes.registerSeeker ||
          loc == AppRoutes.splash ||
          loc == AppRoutes.onboarding;

      // Admin routes selalu bisa diakses langsung (untuk demo)
      final isAdminRoute =
          loc == AppRoutes.adminMediation || loc == AppRoutes.adminVerification;

      // Tunggu loading
      if (userState.isLoading) return null;

      final userData = userState.value;

      // 1. Belum login
      if (userData == null) {
        if (isAdminRoute) return null;
        return isAuthScreen ? null : AppRoutes.login;
      }

      // 2. Suspended
      if (userData.isSuspended) {
        return loc != AppRoutes.suspended ? AppRoutes.suspended : null;
      }
      if (loc == AppRoutes.suspended && !userData.isSuspended) {
        return AppRoutes.splash;
      }

      // 3. Cek verifikasi
      final isEmailVerified = userData.isEmailVerified;
      final isSystemVerified =
          (userData.role == UserRole.expert && userData.isKtmVerified) ||
              (userData.role == UserRole.seeker && userData.isKtpVerified);

      if (!isEmailVerified || !isSystemVerified) {
        if (isAdminRoute) return null;
        if (loc != AppRoutes.pendingVerification) {
          return AppRoutes.pendingVerification;
        }
        return null;
      }

      // 4. Fully verified → arahkan ke dashboard sesuai role
      if (isAuthScreen || loc == AppRoutes.pendingVerification) {
        if (userData.role == UserRole.expert) return AppRoutes.expertDashboard;
        if (userData.role == UserRole.seeker) return AppRoutes.seekerDashboard;
      }

      return null;
    },
    routes: [
      // ─── Auth ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'CariQuest — Splash'),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Onboarding'),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerRole,
        name: 'registerRole',
        builder: (context, state) => const RegisterRoleScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerExpert,
        name: 'registerExpert',
        builder: (context, state) => const RegisterExpertScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerSeeker,
        name: 'registerSeeker',
        builder: (context, state) => const RegisterSeekerScreen(),
      ),
      GoRoute(
        path: AppRoutes.pendingVerification,
        name: 'pendingVerification',
        builder: (context, state) => const PendingVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.suspended,
        name: 'suspended',
        builder: (context, state) => const SuspendedScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        name: 'otpVerification',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Verifikasi OTP'),
      ),

      // ─── Admin (accessible directly for demo) ─────────────────────────────
      GoRoute(
        path: AppRoutes.adminMediation,
        name: 'adminMediation',
        builder: (context, state) => const AdminMediationScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminVerification,
        name: 'adminVerification',
        builder: (context, state) => const AdminVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminHome,
        name: 'adminHome',
        builder: (context, state) => const AdminNavScreen(),
      ),

      // ─── Expert Shell (Bottom Nav) ─────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ExpertNavScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.expertDashboard,
              name: 'expertDashboard',
              builder: (context, state) => const ExpertDashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.expertQuestFeed,
              name: 'expertQuestFeed',
              builder: (context, state) => const ExpertQuestFeedScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.expertOrders,
              name: 'expertOrders',
              builder: (context, state) => const ExpertOrdersScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.expertNotifications,
              name: 'expertNotifications',
              builder: (context, state) => const NotificationScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.expertProfile,
              name: 'expertProfile',
              builder: (context, state) => const ExpertProfileMenuScreen(),
            ),
          ]),
        ],
      ),

      // ─── Seeker Shell (Bottom Nav) ─────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return SeekerNavScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.seekerDashboard,
              name: 'seekerDashboard',
              builder: (context, state) => const SeekerDashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.seekerFastSearch,
              name: 'seekerFastSearch',
              builder: (context, state) => const SeekerFindExpertScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.seekerOrders,
              name: 'seekerOrders',
              builder: (context, state) => const SeekerOrdersScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.seekerNotifications,
              name: 'seekerNotifications',
              builder: (context, state) => const NotificationScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.settings,
              name: 'seekerProfile',
              builder: (context, state) => const SeekerSettingsScreen(),
            ),
          ]),
        ],
      ),

      // ─── Quest & Tracking ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.expertQuestDetail,
        name: 'expertQuestDetail',
        builder: (context, state) =>
            QuestDetailView(questId: state.pathParameters['questId'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.expertActiveQuest,
        name: 'expertActiveQuest',
        builder: (context, state) =>
            QuestTrackingView(questId: state.pathParameters['questId'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.seekerActiveQuest,
        name: 'seekerActiveQuest',
        builder: (context, state) =>
            QuestTrackingView(questId: state.pathParameters['questId'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.seekerPostQuest,
        name: 'seekerPostQuest',
        builder: (context, state) => const SeekerPostQuestScreen(),
      ),
      GoRoute(
        path: AppRoutes.seekerQuestApplicants,
        name: 'seekerQuestApplicants',
        builder: (context, state) => SeekerQuestApplicantsScreen(
            questId: state.pathParameters['questId'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.seekerExpertProfile,
        name: 'seekerExpertProfile',
        builder: (context, state) => ExpertProfileView(
            expertUid: state.pathParameters['expertId'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.seekerRating,
        name: 'seekerRating',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RatingScreen(
            questId: state.pathParameters['questId'] ?? '',
            expertUid: extra['expertUid'] ?? '',
            seekerUid: extra['seekerUid'] ?? '',
          );
        },
      ),

      // ─── Shared ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, s) {
          final extra = s.extra as Map<String, dynamic>? ?? {};
          return ChatScreen(
            questId: s.pathParameters['chatId'] ?? '',
            questTitle: extra['questTitle'] ?? 'Chat',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.expertWalletDashboard,
        name: 'expertWalletDashboard',
        builder: (context, state) => const WalletDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.expertWithdraw,
        name: 'expertWithdraw',
        builder: (context, state) => const WithdrawRequestScreen(),
      ),
      GoRoute(
        path: AppRoutes.payment,
        name: 'payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PaymentView(
            questId: state.pathParameters['questId'] ?? '',
            amount: extra['amount'] ?? 0,
            questTitle: extra['title'] ?? 'Quest Payment',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.faq,
        name: 'faq',
        builder: (context, state) => const _PlaceholderScreen(title: 'FAQ'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Halaman tidak ditemukan: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Kembali ke Login'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ─── Placeholder Screen ───────────────────────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text('Segera hadir: $title', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
