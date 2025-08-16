import 'package:hive/hive.dart';
part 'budget.g.dart';

@HiveType(typeId: 4)
class Budget extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1) 
  late double monthlyLimit;
  
  @HiveField(2)
  late DateTime createdAt;
  
  @HiveField(3)
  late bool isActive;

  Budget({
    required this.id,
    required this.monthlyLimit, 
    DateTime? createdAt,
    this.isActive = true,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
  }
}