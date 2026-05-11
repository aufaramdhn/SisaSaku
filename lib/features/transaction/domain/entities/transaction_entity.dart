import 'package:sisasaku/core/enums.dart';

/// Transaction entity - pure domain object
class TransactionEntity {
  final String id;
  final double nominal;
  final TransactionType jenis;
  final DateTime tanggal;
  final String idKategori;
  final String? deskripsi;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool syncStatus;

  TransactionEntity({
    required this.id,
    required this.nominal,
    required this.jenis,
    required this.tanggal,
    required this.idKategori,
    this.deskripsi,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  TransactionEntity copyWith({
    String? id,
    double? nominal,
    TransactionType? jenis,
    DateTime? tanggal,
    String? idKategori,
    String? deskripsi,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncStatus,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      nominal: nominal ?? this.nominal,
      jenis: jenis ?? this.jenis,
      tanggal: tanggal ?? this.tanggal,
      idKategori: idKategori ?? this.idKategori,
      deskripsi: deskripsi ?? this.deskripsi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nominal == other.nominal &&
          jenis == other.jenis;

  @override
  int get hashCode => id.hashCode ^ nominal.hashCode ^ jenis.hashCode;
}
