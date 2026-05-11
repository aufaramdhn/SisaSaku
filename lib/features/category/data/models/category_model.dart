import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'category_model.g.dart';

/// Category model untuk Isar database
@collection
class CategoryModel {
  Id? isarId;

  /// UUID untuk sync dengan cloud
  @Index(unique: true)
  final String? id;

  /// Nama kategori (e.g., "Makan", "Kos", "Transport")
  final String? nama;

  /// Nama icon (e.g., "utensils", "home", "car")
  final String? ikon;

  /// Warna hex (e.g., "#1D9E75")
  final String? warna;

  /// Timestamp dibuat
  final DateTime? createdAt;

  /// Timestamp diupdate
  final DateTime? updatedAt;

  /// Status sinkronisasi dengan cloud
  final bool syncStatus;

  CategoryModel({
    String? id,
    required this.nama,
    required this.ikon,
    required this.warna,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Copy with
  CategoryModel copyWith({
    String? id,
    String? nama,
    String? ikon,
    String? warna,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncStatus,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      ikon: ikon ?? this.ikon,
      warna: warna ?? this.warna,
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
      'ikon': ikon,
      'warna': warna,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  /// Create from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String?,
      nama: json['nama'] as String,
      ikon: json['ikon'] as String,
      warna: json['warna'] as String,
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
