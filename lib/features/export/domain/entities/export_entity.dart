/// Format ekspor yang didukung
enum ExportFormat {
  pdf('pdf'),
  csv('csv');

  final String label;
  const ExportFormat(this.label);

  String toJson() => label;
  static ExportFormat fromJson(String json) {
    return ExportFormat.values.firstWhere(
      (e) => e.label == json,
      orElse: () => ExportFormat.pdf,
    );
  }
}

/// Export entity - pure domain object
class ExportEntity {
  final String id;
  final ExportFormat format;
  final DateTime startDate;
  final DateTime endDate;
  final String? filePath;
  final DateTime createdAt;

  ExportEntity({
    required this.id,
    required this.format,
    required this.startDate,
    required this.endDate,
    this.filePath,
    required this.createdAt,
  });

  ExportEntity copyWith({
    String? id,
    ExportFormat? format,
    DateTime? startDate,
    DateTime? endDate,
    String? filePath,
    DateTime? createdAt,
  }) {
    return ExportEntity(
      id: id ?? this.id,
      format: format ?? this.format,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          format == other.format &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      id.hashCode ^ format.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}
