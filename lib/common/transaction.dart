import 'package:financial_manager/common/balance_type.dart';
import 'package:financial_manager/cost/cost_db_helper.dart';
import 'package:intl/intl.dart';

class Transaction {
  String accountType = "";
  String accountNumber = "";
  String dateString = "";
  String merchant = "";
  String description = "";
  String cadBalance = "";
  String usdBalance = "";
  BalanceType balanceType = BalanceType.debit;

  DateTime get date => DateFormat("M/d/yyyy").parse(dateString);
  var costCategory = Cost(name: "", budget: 0);

  Transaction({
    required this.accountType,
    required this.accountNumber,
    required this.dateString,
    required this.merchant,
    required this.description,
    required this.cadBalance,
    required this.usdBalance,
    required this.balanceType,
  });
}
