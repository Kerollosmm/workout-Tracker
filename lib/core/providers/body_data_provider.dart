import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/body_data.dart';

class BodyDataProvider with ChangeNotifier {
  final Box<BodyData> _bodyDataBox = Hive.box<BodyData>('body_data');
  static const String _kLatestHeightKey = 'latestHeight';

  List<BodyData> get entries {
    final list = _bodyDataBox.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double? get latestHeight => _bodyDataBox.get(_kLatestHeightKey) as double?;
  void updateLatestHeight(BodyData entry) {
    _bodyDataBox.put(_kLatestHeightKey, entry);
    notifyListeners();
  }

  void addEntry(BodyData entry) {
    _bodyDataBox.add(entry);
    updateLatestHeight(entry);
    notifyListeners();
  }

  void deleteEntry(int index) {
    _bodyDataBox.deleteAt(index);
    notifyListeners();
  }
}
