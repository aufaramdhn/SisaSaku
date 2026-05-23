class SplitBillEntity {
  final String id;
  final String title;
  final double total;
  final bool isEqualSplit;
  final List<String> participantNames;
  final List<double> participantAmounts;
  final List<String> paidParticipantNames;
  final bool isSettled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool syncStatus;

  SplitBillEntity({
    required this.id,
    required this.title,
    required this.total,
    required this.isEqualSplit,
    required this.participantNames,
    required this.participantAmounts,
    required this.paidParticipantNames,
    required this.isSettled,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  double get paidTotal {
    double totalPaid = 0;
    for (var i = 0; i < participantNames.length; i++) {
      if (paidParticipantNames.contains(participantNames[i])) {
        totalPaid += i < participantAmounts.length ? participantAmounts[i] : 0;
      }
    }
    return totalPaid;
  }

  double get myShare =>
      participantAmounts.isEmpty ? 0 : participantAmounts.first;

  SplitBillEntity copyWith({
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
    return SplitBillEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      total: total ?? this.total,
      isEqualSplit: isEqualSplit ?? this.isEqualSplit,
      participantNames: participantNames ?? this.participantNames,
      participantAmounts: participantAmounts ?? this.participantAmounts,
      paidParticipantNames: paidParticipantNames ?? this.paidParticipantNames,
      isSettled: isSettled ?? this.isSettled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
