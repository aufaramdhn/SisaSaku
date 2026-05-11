/// Category entity - pure domain object
class CategoryEntity {
  final String id;
  final String nama;
  final String ikon;
  final String warna;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool syncStatus;

  CategoryEntity({
    required this.id,
    required this.nama,
    required this.ikon,
    required this.warna,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  CategoryEntity copyWith({
    String? id,
    String? nama,
    String? ikon,
    String? warna,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncStatus,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      ikon: ikon ?? this.ikon,
      warna: warna ?? this.warna,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nama == other.nama &&
          ikon == other.ikon &&
          warna == other.warna;

  @override
  int get hashCode =>
      id.hashCode ^ nama.hashCode ^ ikon.hashCode ^ warna.hashCode;
}
