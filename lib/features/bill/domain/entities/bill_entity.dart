import 'package:sisasaku/core/enums.dart';

/// Bill entity - pure domain object
class BillEntity {
  final String id;
  final String nama;
  final double? nominal;
  final DateTime tanggalJatuhTempo;
  final DateTime waktuPengingat;
  final BillStatus status;
  final DateTime? tanggalPembayaran;
  final String? deskripsi;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool syncStatus;

  BillEntity({
    required this.id,
    required this.nama,
    this.nominal,
    required this.tanggalJatuhTempo,
    required this.waktuPengingat,
    required this.status,
    this.tanggalPembayaran,
    this.deskripsi,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  BillEntity copyWith({
    String? id,
    String? nama,
    double? nominal,
    DateTime? tanggalJatuhTempo,
    DateTime? waktuPengingat,
    BillStatus? status,
    DateTime? tanggalPembayaran,
    String? deskripsi,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncStatus,
  }) {
    return BillEntity(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nominal: nominal ?? this.nominal,
      tanggalJatuhTempo: tanggalJatuhTempo ?? this.tanggalJatuhTempo,
      waktuPengingat: waktuPengingat ?? this.waktuPengingat,
      status: status ?? this.status,
      tanggalPembayaran: tanggalPembayaran ?? this.tanggalPembayaran,
      deskripsi: deskripsi ?? this.deskripsi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nama == other.nama &&
          status == other.status;

  @override
  int get hashCode => id.hashCode ^ nama.hashCode ^ status.hashCode;
}
