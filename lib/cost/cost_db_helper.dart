import 'dart:io';

import 'package:hive/hive.dart';

class CostDbHelper {
  static const String _boxName = 'costs';
  static var isInitialized = false;

  CostDbHelper() {
    final appDocumentDir = Directory.current.absolute;
    if (!isInitialized) {
      Hive.init(appDocumentDir.path);
      Hive.registerAdapter(CostAdapter());
      isInitialized = true;
    }
  }

  Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  Future<int> addCost(String name, double budget) async {
    final box = await _openBox();

    final costMap = {
      'name': name,
      'budget': budget,
    };

    final key = await box.add(costMap);
    return key;
  }

  Future<List<Cost>> getAllCosts() async {
    final box = await _openBox();

    final List<Cost> costs = [];
    final allData = box.toMap();
    allData.forEach((key, value) {
      final val = Cost(
        name: value['name'],
        budget: value['budget'],
        key: key,
      );
      costs.add(val);
    });

    return costs;
  }

  Future<void> updateCost(int key, String name, double budget) async {
    final box = await _openBox();

    final costMap = {
      'name': name,
      'budget': budget,
    };

    await box.put(key, costMap);
  }

  Future<void> deleteCost(int key) async {
    final box = await _openBox();
    await box.delete(key);
  }

  Future<void> closeBox() async {
    final box = await Hive.openBox(_boxName);
    await box.close();
  }
}

class Cost {
  final String name;
  final double budget;
  final int? key;

  Cost({required this.name, required this.budget, this.key});
}

class CostAdapter extends TypeAdapter<Cost> {
  @override
  final int typeId = 0;

  @override
  Cost read(BinaryReader reader) {
    final name = reader.readString();
    final budget = reader.readDouble();
    return Cost(name: name, budget: budget);
  }

  @override
  void write(BinaryWriter writer, Cost obj) {
    writer.writeString(obj.name);
    writer.writeDouble(obj.budget);
  }
}
