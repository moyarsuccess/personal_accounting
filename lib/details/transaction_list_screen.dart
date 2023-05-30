import 'dart:ffi';
import 'dart:io';

import 'package:financial_manager/common/csv_generator.dart';
import 'package:financial_manager/common/file_reader.dart';
import 'package:financial_manager/cost/cost_db_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../common/balance_type.dart';
import '../common/transaction.dart';

class TransactionListScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const TransactionListScreen({super.key, required this.transactions});

  @override
  TransactionListScreenState createState() => TransactionListScreenState();
}

class TransactionListScreenState extends State<TransactionListScreen> {
  List<Transaction> transactions = [];
  DateTime? selectedDate;
  final dbHelper = CostDbHelper();
  final List<Cost> costCategories = [Cost(name: "", budget: 0)];
  var filterIncomes = true;

  @override
  void initState() {
    super.initState();
    loadValues();
  }

  void loadValues() async {
    final costs = await dbHelper.getAllCosts();
    costCategories.clear();
    costCategories.addAll(costs);
    fetchTransactions(costCategories[0]);
  }

  Future<void> fetchTransactions(Cost costCategory) async {
    // Fetch the transactions from the file
    List<Transaction> fetchedTransactions = widget.transactions;
    for (var element in fetchedTransactions) {
      element.costCategory = costCategory;
    }

    setState(() {
      transactions = fetchedTransactions;
    });
  }

  void filterTransactions(DateTime selectedDate) {
    setState(() {
      this.selectedDate = selectedDate;
    });
  }

  List<Transaction> getFilteredTransactions() {
    final newTransactions = transactions.toList();
    if (filterIncomes) {
      newTransactions.removeWhere((element) => element.balanceType == BalanceType.credit);
    }
    if (selectedDate == null) {
      return newTransactions;
    } else {
      return newTransactions.where((transaction) {
        final transactionDate =
            DateFormat('MM/dd/yyyy').parse(transaction.dateString);
        return transactionDate.isAfter(selectedDate!) ||
            transactionDate.isAtSameMomentAs(selectedDate!);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Transaction> filteredTransactions = getFilteredTransactions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('RBC Transactions'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          ListTile(
            trailing: ElevatedButton(
              onPressed: () {
                _saveTransactions(filteredTransactions);
              },
              child: const Text("Save"),
            ),
            title: const Text("Saving data"),
          ),
          const SizedBox(
            height: 16,
          ),
          SwitchListTile(
            title: const Text('Filter incomes'),
            value: filterIncomes,
            onChanged: (value) {
              setState(() {
                filterIncomes = value;
              });
            },
          ),
          const SizedBox(
            height: 16,
          ),
          ListTile(
            title: Text(
              selectedDate != null
                  ? 'Selected Date: ${selectedDate.toString()}'
                  : 'Select a Date',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              ).then((pickedDate) {
                if (pickedDate != null) {
                  filterTransactions(pickedDate);
                }
              });
            },
          ),
          const SizedBox(height: 16),
          // Transaction list
          Expanded(
            child: ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return ListTile(
                  title: Text(transaction.merchant.isEmpty
                      ? transaction.description
                      : transaction.merchant),
                  subtitle: Text(transaction.dateString),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<Cost>(
                        value: transactions[index].costCategory,
                        items: costCategories.map((Cost value) {
                          return DropdownMenuItem<Cost>(
                            value: value,
                            child: Text(value.name),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            transactions[index].costCategory = newValue!;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(transaction.cadBalance.isEmpty
                          ? transaction.usdBalance
                          : transaction.cadBalance),
                      const SizedBox(width: 16),
                      Text(transaction.balanceType.name),
                    ],
                  ),
                  tileColor: transaction.balanceType == BalanceType.credit
                      ? Colors.green
                      : Colors.tealAccent,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveTransactions(List<Transaction> transactions) async {
    final csvString = convertTransactionsToCSV(transactions);
    final dir = await openFileSaveDialog();
    String fileName = 'transactions.csv';
    String filePath = path.join(dir, fileName);
    File file = File(filePath);
    await file.writeAsString(csvString);
  }
}
