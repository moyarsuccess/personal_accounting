import 'package:financial_manager/common/transaction.dart';

import 'balance_type.dart';

String convertTransactionsToCSV(List<Transaction> transactions) {
  // Create the header row
  final header = [
    'Date',
    'Merchant',
    'Balance',
    'Balance Type',
    'Cost Category Name',
  ].join(',');

  // Create a List<String> to store the converted transaction strings
  List<String> transactionStrings = [];

  // Add the header row to the transaction strings
  transactionStrings.add(header);

  // Convert each transaction to a string representation
  for (var transaction in transactions) {
    if (transaction.balanceType == BalanceType.credit) {
      continue;
    }
    String transactionString = [
      transaction.dateString,
      transaction.merchant,
      transaction.cadBalance,
      transaction.balanceType.toString(),
      transaction.costCategory.name,
    ].join(',');

    // Add the transaction string to the list
    transactionStrings.add(transactionString);
  }

  // Join all transaction strings with a newline character
  return transactionStrings.join('\n');
}
