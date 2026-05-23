import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'split_bill_model.g.dart';

@collection
class SplitBillModel {
  Id? isarId;

  @Index(unique: true)
  final String? id;

  final String? title;
  final double? total;
  final bool isEqualSplit;
  final List<String> participantNames;
  final List<double> participantAmounts;
  final List<String> paidParticipantNames;

  @Index()
  final bool isSettled;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool syncStatus;

  SplitBillModel({
    String? id,
    required this.title,
    required this.total,
    required this.isEqualSplit,
    required this.participantNames,
    required this.participantAmounts,
    required this.paidParticipantNames,
    this.isSettled = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  static bool _allPaid(List<String> names, List<String> paid) {
    return names.isNotEmpty && names.every(paid.contains);
  }

  SplitBillModel copyWith({
    String? id,
    String? title,
    double? total,
    bool? isEqualSplit,
    List<String>? participantNames,
    List<double>? participantAmounts,
    List<String>? paidParticipantNames,
    bool? isSettled,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncStatus,
  }) {
    final nextNames = participantNames ?? this.participantNames;
    final nextPaid = paidParticipantNames ?? this.paidParticipantNames;
    return SplitBillModel(
      id: id ?? this.id,
      title: title ?? this.title,
      total: total ?? this.total,
      isEqualSplit: isEqualSplit ?? this.isEqualSplit,
      participantNames: nextNames,
      participantAmounts: participantAmounts ?? this.participantAmounts,
      paidParticipantNames: nextPaid,
      isSettled: isSettled ?? _allPaid(nextNames, nextPaid),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
