// lib/features/profile/services/profile_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/errors/failure.dart';
import '../../../shared/models/models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileRepository {
  final MockData _db = MockData.instance;

  Future<ProfileModel?> getProfile(String uid) async {
    try {
      return _db.profiles.firstWhere((p) => p.uid == uid);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile(ProfileModel profile) async {
    final idx = _db.profiles.indexWhere((p) => p.uid == profile.uid);
    if (idx != -1) {
      _db.profiles[idx] = profile;
      _db.emitProfiles();
    }
  }

  Stream<ProfileModel?> profileStream(String uid) {
    return _db.profilesStream.map((profiles) {
      try {
        return profiles.firstWhere((p) => p.uid == uid);
      } catch (_) {
        return null;
      }
    });
  }
}
