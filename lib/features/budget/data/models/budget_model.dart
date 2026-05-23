import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'budget_model.g.dart';

@collection
class BudgetModel {
  Id? isarId;

  @Index(unique: true)
  final String? id;

  @Index()
  final String? idKategori;

  final String? namaKategori;
  final double? limit;

  @Index()
  final String? period;

  @Index()
  final int? month;

  @Index()
  final int? year;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool syncStatus;

  BudgetModel({
    String? id,
    required this.idKategori,
    required this.namaKategori,
    required this.limit,
    this.period = 'monthly',
    required this.month,
    required this.year,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  BudgetModel copyWith({
    String? id,
    String? idKategori,
    String? namaKategori,
    double? limit,
    String? period,
    int? month,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncStatus,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      idKategori: idKategori ?? this.idKategori,
      namaKategori: namaKategori ?? this.namaKategori,
      limit: limit ?? this.limit,
      period: period ?? this.period,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
