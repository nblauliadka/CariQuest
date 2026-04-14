// lib/shared/models/profile_model.dart

import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String uid;
  final String displayName;
  final String bio;
  final String avatarUrl;
  
  // Expert Arrays
  final List<String> skillTags;
  final List<String> albumUrls;
  final List<String> achievements;
  
  // Perks
  final bool isVerifiedPro;
  final DateTime? boostActiveUntil;

  const ProfileModel({
    required this.uid,
    required this.displayName,
    this.bio = '',
    this.avatarUrl = '',
    this.skillTags = const [],
    this.albumUrls = const [],
    this.achievements = const [],
    this.isVerifiedPro = false,
    this.boostActiveUntil,
  });

  ProfileModel copyWith({
    String? uid,
    String? displayName,
    String? bio,
    String? avatarUrl,
    List<String>? skillTags,
    List<String>? albumUrls,
    List<String>? achievements,
    bool? isVerifiedPro,
    DateTime? boostActiveUntil,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      skillTags: skillTags ?? this.skillTags,
      albumUrls: albumUrls ?? this.albumUrls,
      achievements: achievements ?? this.achievements,
      isVerifiedPro: isVerifiedPro ?? this.isVerifiedPro,
      boostActiveUntil: boostActiveUntil ?? this.boostActiveUntil,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'skillTags': skillTags,
      'albumUrls': albumUrls,
      'achievements': achievements,
      'isVerifiedPro': isVerifiedPro,
      'boostActiveUntil': boostActiveUntil?.toIso8601String(),
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProfileModel(
      uid: documentId,
      displayName: map['displayName'] ?? '',
      bio: map['bio'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      skillTags: List<String>.from(map['skillTags'] ?? []),
      albumUrls: List<String>.from(map['albumUrls'] ?? []),
      achievements: List<String>.from(map['achievements'] ?? []),
      isVerifiedPro: map['isVerifiedPro'] ?? false,
      boostActiveUntil: map['boostActiveUntil'] != null 
          ? DateTime.parse(map['boostActiveUntil']) 
          : null,
    );
  }

  @override
  List<Object?> get props => [
        uid, displayName, bio, avatarUrl,
        skillTags, albumUrls, achievements,
        isVerifiedPro, boostActiveUntil
      ];
}
