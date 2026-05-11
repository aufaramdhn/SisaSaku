import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/services/isar_service.dart';

final isarProvider = Provider<Isar>((ref) {
  final isarService = IsarService();
  // Initialized in main before app start; this is a fallback hook.
  return isarService.isar;
});
