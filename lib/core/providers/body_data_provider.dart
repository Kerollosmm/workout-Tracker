import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/body_data.dart';

class BodyDataProvider with ChangeNotifier {
  final Box<BodyData> _bodyDataBox = Hive.box<BodyData>('body_data');

  List<BodyData> get entries {
    final list = _bodyDataBox.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void addEntry(BodyData entry) {
    _bodyDataBox.add(entry);
    notifyListeners();
  }

  void deleteEntry(int index) {
    _bodyDataBox.deleteAt(index);
    notifyListeners();
  }

  double? getLatestBMI() {
    if (entries.isEmpty) return null;
    final latest = entries.first;
    if (latest.height == 0) return null;
    return latest.weight / (latest.height * latest.height);
  }
} 