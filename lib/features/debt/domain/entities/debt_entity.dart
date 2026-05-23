class DebtEntity {
  final String id;
  final String person;
  final double amount;
  final DateTime date;
  final String? notes;
  final String type;
  final bool isSettled;
  final DateTime? settledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool syncStatus;

  DebtEntity({
    required this.id,
    required this.person,
    required this.amount,
    required this.date,
    this.notes,
    required this.type,
    required this.isSettled,
    this.settledAt,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  DebtEntity copyWith({
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
    return DebtEntity(
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
