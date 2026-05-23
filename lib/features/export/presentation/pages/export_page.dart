import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';
import 'package:sisasaku/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key});

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> {
  String _selectedFormat = 'csv';
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(
      monthlyTransactionsProvider((_selectedMonth.month, _selectedMonth.year)),
    );
    final categories = ref.watch(categoriesProvider).value ?? [];
    final categoryMap = {
      for (final category in categories) category.id: category.nama,
    };

    return Scaffold(
      backgroundColor: AppColors.bgSecondaryOf(context),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            left: -40,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 240,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.decorativeBlurOf(context, alpha: 0.4),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Gagal memuat transaksi: $err')),
              data: (transactions) {
                final preview = _PreviewData.fromTransactions(transactions);
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: AppSpacing.xl),
                      _buildMonthSelector(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildFormatSelector(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildPreviewCard(preview),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            MediaQuery.of(context).padding.bottom + AppSpacing.md,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () async {
                final transactions =
                    transactionsAsync.value ?? const <TransactionEntity>[];
                await _export(context, transactions, categoryMap);
              },
              icon: Icon(
                _selectedFormat == 'csv'
                    ? Icons.description_outlined
                    : Icons.picture_as_pdf_outlined,
              ),
              label: Text('Ekspor ${_selectedFormat.toUpperCase()}'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: AppColors.textSecondaryOf(context)),
          style: IconButton.styleFrom(backgroundColor: AppColors.bgPrimaryOf(context)),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          'Ekspor Data',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: AppColors.textPrimaryOf(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgPrimaryOf(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month - 1,
              );
            }),
            icon: Icon(
              Icons.chevron_left,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
          Text(
            _monthLabel(_selectedMonth),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month + 1,
              );
            }),
            icon: Icon(
              Icons.chevron_right,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Format File',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryOf(context),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildFormatCard(
                label: 'CSV',
                icon: Icons.description_outlined,
                isSelected: _selectedFormat == 'csv',
                onTap: () => setState(() => _selectedFormat = 'csv'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildFormatCard(
                label: 'PDF',
                icon: Icons.picture_as_pdf_outlined,
                isSelected: _selectedFormat == 'pdf',
                onTap: () => setState(() => _selectedFormat = 'pdf'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.primaryLight : AppColors.bgPrimaryOf(context),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.borderColorOf(context),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.textSecondaryOf(context),
                size: 32,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.textSecondaryOf(context),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(_PreviewData preview) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgPrimaryOf(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pratinjau',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPreviewRow('Periode', _monthLabel(_selectedMonth)),
          Divider(height: 24, color: AppColors.borderColorOf(context)),
          _buildPreviewRow('Total Transaksi', '${preview.totalTransaksi}'),
          const SizedBox(height: AppSpacing.sm),
          _buildPreviewRow(
            'Pemasukan',
            CurrencyFormatter.format(preview.pemasukan),
            valueColor: AppColors.successColor,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPreviewRow(
            'Pengeluaran',
            CurrencyFormatter.format(preview.pengeluaran),
            valueColor: AppColors.tertiary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPreviewRow(
            'Saldo',
            CurrencyFormatter.format(preview.saldo),
            valueColor: AppColors.primaryColor,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryOf(context),
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimaryOf(context),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<void> _export(
    BuildContext context,
    List<TransactionEntity> transactions,
    Map<String, String> categoryMap,
  ) async {
    final directory = await _resolveExportDirectory();
    final extension = _selectedFormat == 'pdf' ? 'pdf' : 'csv';
    final fileName =
        'sisasaku-${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}.$extension';
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    if (_selectedFormat == 'pdf') {
      final bytes = await _buildPdf(transactions, categoryMap);
      await file.writeAsBytes(bytes, flush: true);
    } else {
      await file.writeAsString(_buildCsv(transactions, categoryMap));
    }

    if (!context.mounted) return;
    await FeedbackDialog.showSuccess<void>(
      context,
      title: 'Ekspor selesai',
      message: 'File ${extension.toUpperCase()} tersimpan di:\n${file.path}',
    );
  }

  Future<Directory> _resolveExportDirectory() async {
    if (Platform.isAndroid) {
      const androidCandidates = [
        '/storage/emulated/0/Download',
        '/sdcard/Download',
      ];
      for (final path in androidCandidates) {
        try {
          final directory = Directory(path);
          if (await directory.exists()) {
            return directory;
          }
          await directory.create(recursive: true);
          if (await directory.exists()) {
            return directory;
          }
        } catch (_) {
          // Try the next known Android downloads path.
        }
      }
    }

    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) {
        await downloads.create(recursive: true);
        return downloads;
      }
    } catch (_) {
      // Fallback to app documents when Downloads is unavailable.
    }
    return getApplicationDocumentsDirectory();
  }

  String _buildCsv(
    List<TransactionEntity> transactions,
    Map<String, String> categoryMap,
  ) {
    final rows = <String>[
      'Tanggal,Jenis,Kategori,Deskripsi,Nominal',
      ...transactions.map((tx) {
        final date = DateFormat('yyyy-MM-dd').format(tx.tanggal);
        final type = tx.jenis == TransactionType.income
            ? 'Pemasukan'
            : 'Pengeluaran';
        final category = _csvEscape(
          categoryMap[tx.idKategori] ?? tx.idKategori,
        );
        final description = _csvEscape(tx.deskripsi ?? '');
        return '$date,$type,$category,$description,${tx.nominal}';
      }),
    ];
    return rows.join('\n');
  }

  Future<List<int>> _buildPdf(
    List<TransactionEntity> transactions,
    Map<String, String> categoryMap,
  ) async {
    final document = pw.Document();
    final preview = _PreviewData.fromTransactions(transactions);
    final periodLabel = _monthLabel(_selectedMonth);
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final rows = transactions.map((tx) {
      return [
        dateFormat.format(tx.tanggal),
        tx.jenis == TransactionType.income ? 'Pemasukan' : 'Pengeluaran',
        categoryMap[tx.idKategori] ?? tx.idKategori,
        tx.deskripsi?.trim().isNotEmpty == true ? tx.deskripsi!.trim() : '-',
        currency.format(tx.nominal),
      ];
    }).toList();

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(28),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        build: (context) => [
          pw.Text(
            'Laporan SisaSaku',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal800,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Periode $periodLabel',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.teal50,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _pdfMetric('Transaksi', '${preview.totalTransaksi}'),
                _pdfMetric('Pemasukan', currency.format(preview.pemasukan)),
                _pdfMetric('Pengeluaran', currency.format(preview.pengeluaran)),
                _pdfMetric('Saldo', currency.format(preview.saldo)),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          if (rows.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Text(
                'Belum ada transaksi pada periode ini.',
                style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey700,
                ),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: const [
                'Tanggal',
                'Jenis',
                'Kategori',
                'Deskripsi',
                'Nominal',
              ],
              data: rows,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.teal700,
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.black,
              ),
              cellAlignments: {4: pw.Alignment.centerRight},
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.4),
                ),
              ),
            ),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _pdfMetric(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.teal900,
          ),
        ),
      ],
    );
  }

  String _csvEscape(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _PreviewData {
  final double pemasukan;
  final double pengeluaran;
  final double saldo;
  final int totalTransaksi;

  const _PreviewData({
    required this.pemasukan,
    required this.pengeluaran,
    required this.saldo,
    required this.totalTransaksi,
  });

  factory _PreviewData.fromTransactions(List<TransactionEntity> transactions) {
    final pemasukan = transactions
        .where((tx) => tx.jenis == TransactionType.income)
        .fold<double>(0, (sum, tx) => sum + tx.nominal);
    final pengeluaran = transactions
        .where((tx) => tx.jenis == TransactionType.expense)
        .fold<double>(0, (sum, tx) => sum + tx.nominal);
    return _PreviewData(
      pemasukan: pemasukan,
      pengeluaran: pengeluaran,
      saldo: pemasukan - pengeluaran,
      totalTransaksi: transactions.length,
    );
  }
}
