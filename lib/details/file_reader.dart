import 'package:financial_manager/common/balance_type.dart';
import 'package:financial_manager/common/file_reader.dart';

import '../common/transaction.dart';

Future<List<Transaction>> readRbcFile() async {
  final lines = await openFileBrowser();
  final pureLines = lines.sublist(1, lines.length - 1);
  final List<Transaction> list = [];
  for (String line in pureLines) {
    final arr = line.split(",");
    final accountType = arr[0];
    final accountNumber = arr[1];
    final date = arr[2];
    final merchant = arr[4];
    final description = arr[4];
    final cadBalance = arr[6];
    final usdBalance = arr[7];
    final finalBalance = cadBalance.isNotEmpty ? cadBalance : usdBalance;
    BalanceType balanceType = creditOrDebit(finalBalance);
    final rbcCredit = Transaction(
      accountType: accountType,
      accountNumber: accountNumber,
      dateString: date,
      merchant: merchant,
      description: description,
      cadBalance: cadBalance,
      usdBalance: usdBalance,
      balanceType: balanceType,
    );
    list.add(rbcCredit);
  }

  return list;
}

Future<List<Transaction>> readCreditScotiaFile() async {
  final lines = await openFileBrowser();
  final pureLines = lines.sublist(1, lines.length - 1);
  final List<Transaction> list = [];
  for (String line in pureLines) {
    final arr = line.split(",");
    final date = arr[0];
    final merchant = arr[1];
    final cadBalance = arr[2];
    BalanceType balanceType = creditOrDebit(cadBalance);
    final rbcCredit = Transaction(
      accountType: "",
      accountNumber: "",
      dateString: date,
      merchant: merchant,
      description: "",
      cadBalance: cadBalance,
      usdBalance: "",
      balanceType: balanceType,
    );
    list.add(rbcCredit);
  }

  return list;
}

Future<List<Transaction>> readChequingScotiaFile() async {
  final lines = await openFileBrowser();
  final pureLines = lines.sublist(1, lines.length - 1);
  final List<Transaction> list = [];
  for (String line in pureLines) {
    final arr = line.split(",");
    final date = arr[0];
    final merchant = arr[4];
    final cadBalance = arr[1];
    BalanceType balanceType = creditOrDebit(cadBalance);
    final rbcCredit = Transaction(
      accountType: "",
      accountNumber: "",
      dateString: date,
      merchant: merchant,
      description: "",
      cadBalance: cadBalance,
      usdBalance: "",
      balanceType: balanceType,
    );
    list.add(rbcCredit);
  }

  return list;
}

BalanceType creditOrDebit(String balance) {
  if (balance.isEmpty) return BalanceType.none;
  if (balance.startsWith("-")) {
    return BalanceType.debit;
  } else {
    return BalanceType.credit;
  }
}
