import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'bill_model.g.dart';

/// Bill model untuk Isar database
@collection
class BillModel {
  Id? isarId;

  /// UUID untuk sync dengan cloud
  @Index(unique: true)
  final String? id;

  /// Nama tagihan (e.g., "Kos Bulanan", "Internet")
  final String? nama;

  /// Nominal tagihan (opsional)
  final double? nominal;

  /// Tanggal jatuh tempo
  @Index()
  final DateTime? tanggalJatuhTempo;

  /// Waktu pengingat notifikasi
  @Index()
  final DateTime? waktuPengingat;

  /// Status tagihan (stored as string)
  @Index()
  final String? status; // "upcoming", "pending", "overdue", "paid"

  /// Tanggal pembayaran (jika sudah lunas)
  final DateTime? tanggalPembayaran;

  /// Deskripsi tagihan (opsional)
  final String? deskripsi;

  /// Timestamp dibuat
  final DateTime? createdAt;

  /// Timestamp diupdate
  final DateTime? updatedAt;

  /// Status sinkronisasi dengan cloud
  final bool syncStatus;

  BillModel({
    String? id,
    required this.nama,
    this.nominal,
    required this.tanggalJatuhTempo,
    required this.waktuPengingat,
    this.status = 'upcoming',
    this.tanggalPembayaran,
    this.deskripsi,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Copy with
  BillModel copyWith({
    String? id,
    String? nama,
    double? nominal,
    DateTime? tanggalJatuhTempo,
    DateTime? waktuPengingat,
    String? status,
    DateTime? tanggalPembayaran,
    String? deskripsi,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncStatus,
  }) {
    return BillModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nominal: nominal ?? this.nominal,
      tanggalJatuhTempo:
          tanggalJatuhTempo ?? this.tanggalJatuhTempo ?? DateTime.now(),
      waktuPengingat: waktuPengingat ?? this.waktuPengingat ?? DateTime.now(),
      status: status ?? this.status ?? 'upcoming',
      tanggalPembayaran: tanggalPembayaran ?? this.tanggalPembayaran,
      deskripsi: deskripsi ?? this.deskripsi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nominal': nominal,
      'tanggalJatuhTempo': tanggalJatuhTempo?.toIso8601String(),
      'waktuPengingat': waktuPengingat?.toIso8601String(),
      'status': status,
      'tanggalPembayaran': tanggalPembayaran?.toIso8601String(),
      'deskripsi': deskripsi,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  /// Create from JSON
  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as String?,
      nama: json['nama'] as String? ?? '',
      nominal: (json['nominal'] as num?)?.toDouble(),
      tanggalJatuhTempo: json['tanggalJatuhTempo'] != null
          ? DateTime.parse(json['tanggalJatuhTempo'] as String)
          : DateTime.now(),
      waktuPengingat: json['waktuPengingat'] != null
          ? DateTime.parse(json['waktuPengingat'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'upcoming',
      tanggalPembayaran: json['tanggalPembayaran'] != null
          ? DateTime.parse(json['tanggalPembayaran'] as String)
          : null,
      deskripsi: json['deskripsi'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      syncStatus: json['syncStatus'] as bool? ?? false,
    );
  }
}
