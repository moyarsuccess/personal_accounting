import 'package:financial_manager/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'cost_db_helper.dart';

class CostManagementPage extends StatefulWidget {
  const CostManagementPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CostManagementState createState() => _CostManagementState();
}

class _CostManagementState extends State<CostManagementPage> {
  final CostDbHelper dbHelper = CostDbHelper();
  int editingIndex = -1;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  var _allCategorySum = 0.0;
  List<Cost> costs = [];

  @override
  void initState() {
    super.initState();
    getCosts();
  }

  Future<void> getCosts() async {
    final List<Cost> retrievedCosts = await dbHelper.getAllCosts();
    setState(() {
      _allCategorySum = 0;
      for (var element in retrievedCosts) {
        _allCategorySum += element.budget;
      }
      costs = retrievedCosts;
    });
  }

  void addCost() {
    String categoryName = nameController.text;
    double budget = double.tryParse(budgetController.text) ?? 0.0;

    setState(() {
      add(categoryName, budget);
      resetForm();
    });
  }

  Future<void> add(String name, double budget) async {
    await dbHelper.addCost(name, budget);
  }

  void updateCost() {
    String categoryName = nameController.text;
    double budget = double.tryParse(budgetController.text) ?? 0.0;

    setState(() {
      update(categoryName, budget);
      resetForm();
    });
  }

  void resetForm() {
    nameController.text = '';
    budgetController.text = '';
    editingIndex = -1;
    costs.clear();
    getCosts();
  }

  Future<void> update(String name, double budget) async {
    final Cost costToUpdate = costs[editingIndex];

    await dbHelper.updateCost(costToUpdate.key ?? 0, name, budget);
  }

  Future<void> deleteCost(int index) async {
    final Cost costToDelete = costs[index];

    await dbHelper.deleteCost(costToDelete.key ?? 0);

    setState(() {
      costs.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(costManagementPageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Cost Category Name',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: budgetController,
              decoration: const InputDecoration(
                labelText: 'Budget',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (editingIndex == -1) {
                  addCost();
                } else {
                  updateCost();
                }
              },
              child: Text(editingIndex == -1 ? 'Add Cost' : 'Update Cost'),
            ),
            const SizedBox(height: 16.0),
            Text('Sum: $_allCategorySum'),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: costs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(costs[index].name),
                    subtitle: Text(
                        'Budget: \$${costs[index].budget.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            startEditing(index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteCost(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startEditing(int index) {
    setState(() {
      nameController.text = costs[index].name;
      budgetController.text = costs[index].budget.toString();
      editingIndex = index;
    });
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}
