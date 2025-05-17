import 'package:hive/hive.dart';
part 'user_settings.g.dart';

@HiveType(typeId: 3)
class UserSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;
  
  @HiveField(1)
  List<String> notificationDays;
  
  @HiveField(2)
  String? notificationTime;
  
  @HiveField(3)
  DateTime? dateOfBirth;
  
  @HiveField(4)
  String sex;
  
  @HiveField(5)
  String height;
  
  @HiveField(6)
  double weight;
  
  @HiveField(7)
  bool isMetric;

  @HiveField(8)
  String language;

  @HiveField(9)
  String weightUnit;
  
  UserSettings({
    this.isDarkMode = false,
    this.notificationDays = const [],
    this.notificationTime,
    this.dateOfBirth,
    this.sex = '',
    this.height = '',
    this.weight = 0.0,
    this.isMetric = false,
    this.language = 'en',
    this.weightUnit = 'kg',
  });
}
