// lib/shared/models/user_model.dart
import 'package:equatable/equatable.dart';
import '../../core/constants/app_enums.dart';

class UserModel extends Equatable {
  final String uid;
  final UserRole role;
  final String email;
  final String phone;
  final String displayName;

  final String? nim;
  final String? faculty;
  final String? major;

  final bool isEmailVerified;
  final bool isKtmVerified;
  final bool isKtpVerified;
  final String? ktmPhotoUrl;
  final String? ktpPhotoUrl;

  final ExpertRank rank;
  final int expPoints;
  final int totalQuestsDone;
  final double ratingAvg;
  final int ratingCount;

  final int saldoActive;
  final int saldoPending;

  final bool isSuspended;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime lastActive;

  const UserModel({
    required this.uid,
    required this.role,
    required this.email,
    required this.phone,
    this.displayName = '',
    this.nim,
    this.faculty,
    this.major,
    this.isEmailVerified = false,
    this.isKtmVerified = false,
    this.isKtpVerified = false,
    this.ktmPhotoUrl,
    this.ktpPhotoUrl,
    this.rank = ExpertRank.newcomer,
    this.expPoints = 0,
    this.totalQuestsDone = 0,
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    this.saldoActive = 0,
    this.saldoPending = 0,
    this.isSuspended = false,
    this.deviceId,
    required this.createdAt,
    required this.lastActive,
  });

  UserModel copyWith({
    String? uid,
    UserRole? role,
    String? email,
    String? phone,
    String? displayName,
    String? nim,
    String? faculty,
    String? major,
    bool? isEmailVerified,
    bool? isKtmVerified,
    bool? isKtpVerified,
    String? ktmPhotoUrl,
    String? ktpPhotoUrl,
    ExpertRank? rank,
    int? expPoints,
    int? totalQuestsDone,
    double? ratingAvg,
    int? ratingCount,
    int? saldoActive,
    int? saldoPending,
    bool? isSuspended,
    String? deviceId,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      nim: nim ?? this.nim,
      faculty: faculty ?? this.faculty,
      major: major ?? this.major,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isKtmVerified: isKtmVerified ?? this.isKtmVerified,
      isKtpVerified: isKtpVerified ?? this.isKtpVerified,
      ktmPhotoUrl: ktmPhotoUrl ?? this.ktmPhotoUrl,
      ktpPhotoUrl: ktpPhotoUrl ?? this.ktpPhotoUrl,
      rank: rank ?? this.rank,
      expPoints: expPoints ?? this.expPoints,
      totalQuestsDone: totalQuestsDone ?? this.totalQuestsDone,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      saldoActive: saldoActive ?? this.saldoActive,
      saldoPending: saldoPending ?? this.saldoPending,
      isSuspended: isSuspended ?? this.isSuspended,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role.name,
      'email': email,
      'phone': phone,
      'displayName': displayName,
      'nim': nim,
      'faculty': faculty,
      'major': major,
      'isEmailVerified': isEmailVerified,
      'isKtmVerified': isKtmVerified,
      'isKtpVerified': isKtpVerified,
      'ktmPhotoUrl': ktmPhotoUrl,
      'ktpPhotoUrl': ktpPhotoUrl,
      'rank': rank.name,
      'expPoints': expPoints,
      'totalQuestsDone': totalQuestsDone,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'saldoActive': saldoActive,
      'saldoPending': saldoPending,
      'isSuspended': isSuspended,
      'deviceId': deviceId,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  // ─── FIX: Handle String parsing ─────────────────────
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    return DateTime.now();
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.seeker,
      ),
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      displayName: map['displayName'] ?? '',
      nim: map['nim'],
      faculty: map['faculty'],
      major: map['major'],
      isEmailVerified: map['isEmailVerified'] ?? false,
      isKtmVerified: map['isKtmVerified'] ?? false,
      isKtpVerified: map['isKtpVerified'] ?? false,
      ktmPhotoUrl: map['ktmPhotoUrl'],
      ktpPhotoUrl: map['ktpPhotoUrl'],
      rank: ExpertRank.values.firstWhere(
        (e) => e.name == map['rank'],
        orElse: () => ExpertRank.newcomer,
      ),
      expPoints: map['expPoints']?.toInt() ?? 0,
      totalQuestsDone: map['totalQuestsDone']?.toInt() ?? 0,
      ratingAvg: map['ratingAvg']?.toDouble() ?? 0.0,
      ratingCount: map['ratingCount']?.toInt() ?? 0,
      saldoActive: map['saldoActive']?.toInt() ?? 0,
      saldoPending: map['saldoPending']?.toInt() ?? 0,
      isSuspended: map['isSuspended'] ?? false,
      deviceId: map['deviceId'],
      createdAt: _parseDate(map['createdAt']),
      lastActive: _parseDate(map['lastActive']),
    );
  }

  @override
  List<Object?> get props => [
        uid, role, email, phone, displayName, nim, faculty, major,
        isEmailVerified, isKtmVerified, isKtpVerified,
        ktmPhotoUrl, ktpPhotoUrl,
        rank, expPoints, totalQuestsDone, ratingAvg, ratingCount,
        saldoActive, saldoPending, isSuspended, deviceId, createdAt, lastActive,
      ];
}
