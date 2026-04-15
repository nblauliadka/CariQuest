// lib/features/auth/services/auth_repository.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/models.dart';
import '../../../core/errors/failure.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  final MockData _db = MockData.instance;
  UserModel? _currentUser;
  
  // Dedicated stream controller to emulate FirebaseAuth.authStateChanges
  final _authStateController = StreamController<UserModel?>.broadcast();
  
  // Riverpod/GoRouter listeners might attach *after* `init()` runs (especially on web),
  // so we must always emit the current value immediately (BehaviorSubject-like).
  Stream<UserModel?> get authStateChange async* {
    yield _currentUser;
    yield* _authStateController.stream;
  }

  UserModel? get currentUser => _currentUser;

  Future<void> init() async {
    _db.initDemoData();
    final prefs = await SharedPreferences.getInstance();
    final savedUid = prefs.getString('demo_logged_in_uid');
    if (savedUid != null) {
      _currentUser = _db.getUser(savedUid);
    }
  }

  Stream<UserModel?> streamUserData(String uid) {
    // Same issue as authStateChange: initial `emitUsers()` can happen before listeners attach.
    // Emit the current snapshot first, then continue streaming updates.
    return Stream<UserModel?>.multi((controller) {
      controller.add(_db.getUser(uid));
      final sub = _db.usersStream.listen((users) {
        try {
          controller.add(users.firstWhere((u) => u.uid == uid));
        } catch (_) {
          controller.add(null);
        }
      }, onError: controller.addError, onDone: controller.close);
      controller.onCancel = () => sub.cancel();
    });
  }

  Future<UserModel?> getUserData(String uid) async {
    return _db.getUser(uid);
  }

  Future<String> uploadVerificationPhoto({
    required String uid,
    required Uint8List bytes,
    required UserRole role,
  }) async {
    return 'https://mock-image.com/ktp-ktm.jpg';
  }

  Future<void> loginWithEmail(String email, String password) async {
    // Basic mock login validation
    final user = _db.users.firstWhere((u) => u.email == email, orElse: () => throw const Failure('Email not found'));
    if (password != 'demo123') throw const Failure('Password salah (gunakan: demo123)');
    
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('demo_logged_in_uid', user.uid);
    
    // Emit the new auth state so the router reacts
    _authStateController.add(_currentUser);
  }

  Future<String> registerExpert({
    required String email,
    required String password,
    required String nim,
    required String name,
    required String phone,
    String? faculty,
    String? major,
  }) async {
    throw const Failure('Registrasi dinonaktifkan di mode Demo MVP.');
  }

  Future<String> registerSeeker({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    throw const Failure('Registrasi dinonaktifkan di mode Demo MVP.');
  }

  Future<void> sendEmailVerification() async {}
  Future<void> checkEmailVerified() async {}

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('demo_logged_in_uid');
    
    // Emit null auth state to log user out visually
    _authStateController.add(null);
  }
}
