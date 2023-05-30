import 'package:financial_manager/common/constants.dart';
import 'package:financial_manager/common/transaction.dart';
import 'package:financial_manager/cost/cost_manager.dart';
import 'package:flutter/material.dart';

import 'details/file_reader.dart';
import 'details/transaction_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: applicationTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  void _openFile(BuildContext context, List<Transaction> transactions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionListScreen(transactions: transactions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(applicationTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _createButton(
                context, const Icon(Icons.house), rbcButtonTitle, Colors.blue,
                () {
              _fetchRbcTransactions(context)
                  .then((value) => _openFile(context, value));
            }),
            const SizedBox(height: 10),
            _createButton(context, const Icon(Icons.house),
                scotiaCreditButtonTitle, Colors.red, () {
              _fetchScotiaCreditTransactions(context)
                  .then((value) => _openFile(context, value));
            }),
            const SizedBox(height: 10),
            _createButton(context, const Icon(Icons.house),
                scotiaChequingButtonTitle, Colors.red, () {
              _fetchScotiaChequingTransactions(context)
                  .then((value) => _openFile(context, value));
            }),
            const SizedBox(height: 10),
            _createButton(context, const Icon(Icons.account_balance_wallet),
                costManagementPageTitle, Colors.orange, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CostManagementPage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<List<Transaction>> _fetchRbcTransactions(BuildContext context) async {
    List<Transaction> transactions = await readRbcFile();
    return transactions;
  }

  Future<List<Transaction>> _fetchScotiaCreditTransactions(
      BuildContext context) async {
    List<Transaction> transactions = await readCreditScotiaFile();
    return transactions;
  }

  Future<List<Transaction>> _fetchScotiaChequingTransactions(
      BuildContext context) async {
    List<Transaction> transactions = await readChequingScotiaFile();
    return transactions;
  }

  Widget _createButton(BuildContext context, Icon icon, String title,
      Color color, Function onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
      onPressed: () {
        onPressed();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8.0),
          Text(title),
          // Button text
        ],
      ),
    );
  }
}
