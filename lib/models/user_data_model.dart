import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String userId;
  String gender;
  int age;
  double height;
  double weight;
  String goal;
  double? bmr;
  double? dailyCalories;

  double? sleepHours;
  DateTime? lastSleepUpdate;

  int? steps;
  DateTime? lastStepsUpdate;

  var name;

  UserData({
    required this.userId,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.goal,
    this.bmr,
    this.dailyCalories,
    this.sleepHours,
    this.lastSleepUpdate,
    this.steps,
    this.lastStepsUpdate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'goal': goal,
      'bmr': bmr,
      'dailyCalories': dailyCalories,
      'sleepHours': sleepHours,
      'lastSleepUpdate': lastSleepUpdate != null
          ? Timestamp.fromDate(lastSleepUpdate!)
          : null,
      'steps': steps,
      'lastStepsUpdate': lastStepsUpdate != null
          ? Timestamp.fromDate(lastStepsUpdate!)
          : null,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map, String userId) {
    return UserData(
      userId: userId,
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      height: (map['height'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      goal: map['goal'] ?? '',
      bmr: map['bmr']?.toDouble(),
      dailyCalories: map['dailyCalories']?.toDouble(),
      sleepHours: map['sleepHours']?.toDouble(),
      lastSleepUpdate: map['lastSleepUpdate'] != null
          ? (map['lastSleepUpdate'] as Timestamp).toDate()
          : null,
      steps: map['steps'] as int?,
      lastStepsUpdate: map['lastStepsUpdate'] != null
          ? (map['lastStepsUpdate'] as Timestamp).toDate()
          : null,
    );
  }
}
