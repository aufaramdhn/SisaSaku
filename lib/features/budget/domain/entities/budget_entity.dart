class BudgetEntity {
  final String id;
  final String idKategori;
  final String namaKategori;
  final double limit;
  final String period;
  final int month;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool syncStatus;

  BudgetEntity({
    required this.id,
    required this.idKategori,
    required this.namaKategori,
    required this.limit,
    required this.period,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  BudgetEntity copyWith({
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
    return BudgetEntity(
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
