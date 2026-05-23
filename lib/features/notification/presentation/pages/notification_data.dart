import 'package:flutter/material.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/features/bill/domain/entities/bill_entity.dart';

enum NotificationKind { bill, sync, budget, general }

class AppNotificationItem {
  final String id;
  final String title;
  final String message;
  final String detail;
  final DateTime createdAt;
  final NotificationKind kind;
  final bool isRead;
  final String? billId;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.detail,
    required this.createdAt,
    required this.kind,
    required this.isRead,
    this.billId,
  });

  IconData get icon {
    return switch (kind) {
      NotificationKind.bill => Icons.receipt_long_outlined,
      NotificationKind.sync => Icons.cloud_done_outlined,
      NotificationKind.budget => Icons.pie_chart_outline,
      NotificationKind.general => Icons.notifications_none_rounded,
    };
  }

  Color get color {
    return switch (kind) {
      NotificationKind.bill => AppColors.warningDark,
      NotificationKind.sync => AppColors.primaryColor,
      NotificationKind.budget => AppColors.dangerColor,
      NotificationKind.general => AppColors.textSecondary,
    };
  }
}

List<AppNotificationItem> buildBillNotifications(
  List<BillEntity> bills,
  Set<String> readIds,
) {
  final now = DateTime.now();
  final actionable =
      bills.where((bill) {
          if (bill.status == BillStatus.paid) return false;
          final daysUntilDue = bill.tanggalJatuhTempo.difference(now).inDays;
          return bill.status == BillStatus.overdue || daysUntilDue <= 3;
        }).toList()
        ..sort((a, b) => a.tanggalJatuhTempo.compareTo(b.tanggalJatuhTempo));

  return actionable.map((bill) {
    final isOverdue =
        bill.status == BillStatus.overdue ||
        bill.tanggalJatuhTempo.isBefore(now);
    final dueLabel = _formatDueLabel(bill.tanggalJatuhTempo, now);
    final notificationId = 'bill-${bill.id}';
    return AppNotificationItem(
      id: notificationId,
      title: isOverdue
          ? '${bill.nama} sudah melewati jatuh tempo'
          : '${bill.nama} mendekati jatuh tempo',
      message: isOverdue
          ? 'Tagihan perlu segera ditandai atau dibayar.'
          : 'Jatuh tempo $dueLabel.',
      detail: isOverdue
          ? '${bill.nama} sudah melewati tanggal jatuh tempo. Cek detail tagihan untuk memperbarui status pembayaran.'
          : '${bill.nama} akan jatuh tempo $dueLabel. Siapkan pembayaran agar catatan bulanan tetap rapi.',
      createdAt: bill.updatedAt,
      kind: NotificationKind.bill,
      isRead: readIds.contains(notificationId),
      billId: bill.id,
    );
  }).toList();
}

String _formatDueLabel(DateTime dueDate, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final diff = due.difference(today).inDays;
  if (diff < 0) return '${diff.abs()} hari lalu';
  if (diff == 0) return 'hari ini';
  if (diff == 1) return 'besok';
  return '$diff hari lagi';
}
