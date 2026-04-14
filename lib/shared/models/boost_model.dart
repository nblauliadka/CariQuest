// lib/shared/models/boost_model.dart

import 'package:equatable/equatable.dart';
import '../../core/constants/app_enums.dart';

class BoostModel extends Equatable {
  final String boostId;
  final String expertUid;
  
  final BoostPackage package;
  
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const BoostModel({
    required this.boostId,
    required this.expertUid,
    required this.package,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'boostId': boostId,
      'expertUid': expertUid,
      'package': package.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory BoostModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BoostModel(
      boostId: documentId,
      expertUid: map['expertUid'] ?? '',
      package: BoostPackage.values.firstWhere((e) => e.name == map['package'], orElse: () => BoostPackage.lite),
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      isActive: map['isActive'] ?? false,
    );
  }

  @override
  List<Object?> get props => [boostId, expertUid, package, startDate, endDate, isActive];
}
