// lib/features/profile/providers/profile_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/profile_repository.dart';
import '../../../shared/models/models.dart';
import '../../../core/errors/failure.dart';
import '../../auth/providers/auth_controller.dart';

// Provides ProfileModel based on UID
final profileProvider = StreamProvider.family<ProfileModel?, String>((ref, uid) {
  return ref.watch(profileRepositoryProvider).profileStream(uid);
});

// Provides current Expert's profile
final currentExpertProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final user = ref.watch(userProvider).value;
  if (user != null) {
    return ref.read(profileRepositoryProvider).getProfile(user.uid);
  }
  return null;
});

final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
  return ProfileController(
    profileRepository: ref.watch(profileRepositoryProvider),
    ref: ref,
  );
});

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _profileRepository;
  final Ref _ref;

  ProfileController({
    required ProfileRepository profileRepository,
    required Ref ref,
  }) : _profileRepository = profileRepository,
       _ref = ref,
       super(const AsyncValue.data(null));

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    List<String>? skillTags,
    String? avatarUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(userProvider).value;
      if (user == null) throw const Failure('User tidak ditemukan');
      
      final currentProfile = await _profileRepository.getProfile(user.uid);
      if (currentProfile == null) throw const Failure('Profil tidak ditemukan');

      final updatedProfile = currentProfile.copyWith(
        displayName: displayName,
        bio: bio,
        skillTags: skillTags,
        avatarUrl: avatarUrl,
      );

      await _profileRepository.updateProfile(updatedProfile);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> addPortfolioImage(String imageUrl) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(userProvider).value;
      if (user == null) throw const Failure('User tidak ditemukan');

      final currentProfile = await _profileRepository.getProfile(user.uid);
      if (currentProfile == null) throw const Failure('Profil tidak ditemukan');

      final updatedAlbum = [...currentProfile.albumUrls, imageUrl];
      await _profileRepository.updateProfile(currentProfile.copyWith(albumUrls: updatedAlbum));
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> removePortfolioImage(String imageUrl) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(userProvider).value;
      if (user == null) throw const Failure('User tidak ditemukan');

      final currentProfile = await _profileRepository.getProfile(user.uid);
      if (currentProfile == null) throw const Failure('Profil tidak ditemukan');

      final updatedAlbum = currentProfile.albumUrls.where((url) => url != imageUrl).toList();
      await _profileRepository.updateProfile(currentProfile.copyWith(albumUrls: updatedAlbum));
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }
}
