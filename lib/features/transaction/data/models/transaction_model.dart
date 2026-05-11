import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'transaction_model.g.dart';

/// Transaction model untuk Isar database
@collection
class TransactionModel {
  Id? isarId;

  /// UUID untuk sync dengan cloud
  @Index(unique: true)
  final String? id;

  /// Jumlah nominal uang
  final double? nominal;

  /// Jenis transaksi (pemasukan/pengeluaran)
  final String?
  jenis; // Stored as string, convert via TransactionType.fromJson()

  /// Tanggal transaksi
  @Index()
  final DateTime? tanggal;

  /// ID kategori (foreign key ke CategoryModel)
  @Index()
  final String? idKategori;

  /// Deskripsi transaksi (opsional)
  final String? deskripsi;

  /// Timestamp dibuat
  final DateTime? createdAt;

  /// Timestamp diupdate
  final DateTime? updatedAt;

  /// Status sinkronisasi dengan cloud
  final bool syncStatus;

  TransactionModel({
    String? id,
    required this.nominal,
    required this.jenis,
    required this.tanggal,
    required this.idKategori,
    this.deskripsi,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Copy with
  TransactionModel copyWith({
    String? id,
    double? nominal,
    String? jenis,
    DateTime? tanggal,
    String? idKategori,
    String? deskripsi,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncStatus,
  }) {
    return TransactionModel(
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

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nominal': nominal,
      'jenis': jenis,
      'tanggal': tanggal?.toIso8601String(),
      'idKategori': idKategori,
      'deskripsi': deskripsi,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  /// Create from JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String?,
      nominal: (json['nominal'] as num).toDouble(),
      jenis: json['jenis'] as String,
      tanggal: DateTime.parse(json['tanggal'] as String),
      idKategori: json['idKategori'] as String,
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
