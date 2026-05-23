import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sisasaku/core/errors/exceptions.dart';
import 'package:sisasaku/features/export/data/models/export_config_model.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';
import 'package:intl/intl.dart';

/// Local datasource untuk Export - menghasilkan file PDF/CSV
class ExportLocalDatasource {
  /// Riwayat ekspor (in-memory, opsional)
  final List<ExportConfigModel> _exportHistory = [];

  /// Generate file PDF dari data transaksi
  Future<ExportConfigModel> generatePdf({
    required DateTime startDate,
    required DateTime endDate,
    required List<TransactionEntity> transactions,
  }) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd/MM/yyyy');
      final currencyFormat = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Laporan Transaksi',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Paragraph(
              text:
                  'Periode: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              headers: ['Tanggal', 'Jenis', 'Kategori', 'Nominal', 'Deskripsi'],
              data: transactions.map((t) {
                return [
                  dateFormat.format(t.tanggal),
                  t.jenis.label == 'masuk' ? 'Pemasukan' : 'Pengeluaran',
                  t.idKategori,
                  currencyFormat.format(t.nominal),
                  t.deskripsi ?? '-',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            _buildSummary(transactions, currencyFormat),
          ],
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/export_$timestamp.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      final config = ExportConfigModel(
        format: 'pdf',
        startDate: startDate,
        endDate: endDate,
        filePath: filePath,
      );

      _exportHistory.add(config);
      return config;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal menghasilkan file PDF: $e',
      );
    }
  }

  /// Generate file CSV dari data transaksi
  Future<ExportConfigModel> generateCsv({
    required DateTime startDate,
    required DateTime endDate,
    required List<TransactionEntity> transactions,
  }) async {
    try {
      final dateFormat = DateFormat('dd/MM/yyyy');
      final buffer = StringBuffer();

      // Header CSV
      buffer.writeln('Tanggal,Jenis,Kategori,Nominal,Deskripsi');

      // Data rows
      for (final t in transactions) {
        final tanggal = dateFormat.format(t.tanggal);
        final jenis = t.jenis.label == 'masuk' ? 'Pemasukan' : 'Pengeluaran';
        final kategori = _escapeCsv(t.idKategori);
        final nominal = t.nominal.toStringAsFixed(0);
        final deskripsi = _escapeCsv(t.deskripsi ?? '');
        buffer.writeln('$tanggal,$jenis,$kategori,$nominal,$deskripsi');
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/export_$timestamp.csv';
      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      final config = ExportConfigModel(
        format: 'csv',
        startDate: startDate,
        endDate: endDate,
        filePath: filePath,
      );

      _exportHistory.add(config);
      return config;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal menghasilkan file CSV: $e',
      );
    }
  }

  /// Get riwayat ekspor
  Future<List<ExportConfigModel>> getExportHistory() async {
    return List.unmodifiable(_exportHistory);
  }

  /// Escape CSV field value
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Build summary section for PDF
  pw.Widget _buildSummary(
    List<TransactionEntity> transactions,
    NumberFormat currencyFormat,
  ) {
    final totalIncome = transactions
        .where((t) => t.jenis.label == 'masuk')
        .fold<double>(0, (sum, t) => sum + t.nominal);
    final totalExpense = transactions
        .where((t) => t.jenis.label == 'keluar')
        .fold<double>(0, (sum, t) => sum + t.nominal);
    final balance = totalIncome - totalExpense;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 5),
        pw.Text(
          'Ringkasan:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text('Total Pemasukan: ${currencyFormat.format(totalIncome)}'),
        pw.Text('Total Pengeluaran: ${currencyFormat.format(totalExpense)}'),
        pw.Text(
          'Saldo: ${currencyFormat.format(balance)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
