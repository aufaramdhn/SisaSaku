import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'debt_model.g.dart';

@collection
class DebtModel {
  Id? isarId;

  @Index(unique: true)
  final String? id;

  final String? person;
  final double? amount;

  @Index()
  final DateTime? date;

  final String? notes;

  @Index()
  final String? type;

  @Index()
  final bool isSettled;

  final DateTime? settledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool syncStatus;

  DebtModel({
    String? id,
    required this.person,
    required this.amount,
    required this.date,
    this.notes,
    required this.type,
    this.isSettled = false,
    this.settledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  DebtModel copyWith({
    String? id,
    String? person,
    double? amount,
    DateTime? date,
    String? notes,
    String? type,
    bool? isSettled,
    DateTime? settledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncStatus,
  }) {
    return DebtModel(
      id: id ?? this.id,
      person: person ?? this.person,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
