// lib/features/auth/providers/auth_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_repository.dart';
import '../../../shared/models/models.dart';
import '../../../core/errors/failure.dart';

// Provides mock auth stream (replaces FirebaseAuth.authStateChanges)
final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChange;
});

// Stream of current user data - reactive to mock data changes
final userProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.read(authRepositoryProvider).streamUserData(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => Stream.value(null),
  );
});

// ─── Controller for UI Actions ────────────────────────────────────────────────
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(authRepository: ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.loginWithEmail(email, password);
      state = const AsyncValue.data(null);
    } on Failure catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> registerExpert({
    required String email,
    required String password,
    required String nim,
    required String name,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.registerExpert(
        email: email,
        password: password,
        nim: nim,
        name: name,
        phone: phone,
      );
      state = const AsyncValue.data(null);
    } on Failure catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> registerSeeker({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.registerSeeker(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      state = const AsyncValue.data(null);
    } on Failure catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> verifyEmailChecked() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.checkEmailVerified();
      state = const AsyncValue.data(null);
    } on Failure catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await _authRepository.sendEmailVerification();
    } catch (e) {
      // Background task — ignore
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _authRepository.logout();
    state = const AsyncValue.data(null);
  }
}
