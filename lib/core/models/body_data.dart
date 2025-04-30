import 'package:hive/hive.dart';
part 'body_data.g.dart';

@HiveType(typeId: 5)
class BodyData extends HiveObject {
  @HiveField(0)
  double weight; // in kg

  @HiveField(1)
  double height; // in meters

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String? note;

  BodyData({
    required this.weight,
    required this.height,
    required this.date,
    this.note,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BodyData &&
           other.weight == weight &&
           other.height == height &&
           other.date == date &&
           other.note == note;
  }

  @override
  int get hashCode => Object.hash(weight, height, date, note);
} 