// Enums untuk SisaSaku

/// Jenis transaksi: pemasukan atau pengeluaran
enum TransactionType {
  income('masuk'),
  expense('keluar');

  final String label;
  const TransactionType(this.label);

  String toJson() => label;
  static TransactionType fromJson(String json) {
    return TransactionType.values.firstWhere(
      (e) => e.label == json,
      orElse: () => TransactionType.expense,
    );
  }
}

/// Status tagihan
enum BillStatus {
  upcoming('akan_datang'),
  pending('akan_jatuh_tempo'),
  overdue('overdue'),
  paid('lunas');

  final String label;
  const BillStatus(this.label);

  String toJson() => label;
  static BillStatus fromJson(String json) {
    return BillStatus.values.firstWhere(
      (e) => e.label == json,
      orElse: () => BillStatus.upcoming,
    );
  }
}
