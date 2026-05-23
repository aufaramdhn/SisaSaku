import 'package:uuid/uuid.dart';
import 'package:sisasaku/features/export/domain/entities/export_entity.dart';

/// Model konfigurasi ekspor - menyimpan metadata ekspor
class ExportConfigModel {
  final String id;
  final String format; // 'pdf' or 'csv'
  final DateTime startDate;
  final DateTime endDate;
  final String? filePath;
  final DateTime createdAt;

  ExportConfigModel({
    String? id,
    required this.format,
    required this.startDate,
    required this.endDate,
    this.filePath,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Copy with
  ExportConfigModel copyWith({
    String? id,
    String? format,
    DateTime? startDate,
    DateTime? endDate,
    String? filePath,
    DateTime? createdAt,
  }) {
    return ExportConfigModel(
      id: id ?? this.id,
      format: format ?? this.format,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'format': format,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ExportConfigModel.fromJson(Map<String, dynamic> json) {
    return ExportConfigModel(
      id: json['id'] as String?,
      format: json['format'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      filePath: json['filePath'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// Convert from ExportEntity
  factory ExportConfigModel.fromEntity(ExportEntity entity) {
    return ExportConfigModel(
      id: entity.id,
      format: entity.format.label,
      startDate: entity.startDate,
      endDate: entity.endDate,
      filePath: entity.filePath,
      createdAt: entity.createdAt,
    );
  }

  /// Convert to ExportEntity
  ExportEntity toEntity() {
    return ExportEntity(
      id: id,
      format: ExportFormat.fromJson(format),
      startDate: startDate,
      endDate: endDate,
      filePath: filePath,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportConfigModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          format == other.format &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      id.hashCode ^ format.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}
