import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sisasaku/features/bill/data/models/bill_model.dart';
import 'package:sisasaku/features/budget/data/models/budget_model.dart';
import 'package:sisasaku/features/category/data/models/category_model.dart';
import 'package:sisasaku/features/debt/data/models/debt_model.dart';
import 'package:sisasaku/features/splitbill/data/models/split_bill_model.dart';
import 'package:sisasaku/features/transaction/data/models/transaction_model.dart';

class IsarService {
  static final IsarService _instance = IsarService._internal();

  late Isar _isar;

  IsarService._internal();

  factory IsarService() {
    return _instance;
  }

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([
      CategoryModelSchema,
      TransactionModelSchema,
      BillModelSchema,
      BudgetModelSchema,
      DebtModelSchema,
      SplitBillModelSchema,
    ], directory: dir.path);
  }

  Isar get isar => _isar;

  Future<void> close() async {
    await _isar.close();
  }
}
