import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addMeal({
    required String mealName,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required String mealType,
    String? portion,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month}-${now.day}';

      final userMealsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('meals')
          .doc(todayKey);

      final docSnapshot = await userMealsRef.get();

      List<Map<String, dynamic>> mealsList = [];

      if (docSnapshot.exists) {
        mealsList = List<Map<String, dynamic>>.from(
          docSnapshot.data()?['meals'] ?? [],
        );
      }

      mealsList.add({
        'name': mealName,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'mealType': mealType,
        'portion': portion ?? '',
        'timestamp': DateTime.now().toIso8601String(),
      });

      int totalCalories = mealsList.fold(
        0,
        (sum, meal) => sum + (meal['calories'] as int),
      );

      int totalProtein = mealsList.fold(
        0,
        (sum, meal) => sum + (meal['protein'] as int),
      );

      int totalCarbs = mealsList.fold(
        0,
        (sum, meal) => sum + (meal['carbs'] as int),
      );

      int totalFat = mealsList.fold(
        0,
        (sum, meal) => sum + (meal['fat'] as int),
      );

      await userMealsRef.set({
        'date': todayKey,
        'meals': mealsList,
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding meal: $e');
      rethrow;
    }
  }

  Future<int> getTodayCalories() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month}-${now.day}';

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('meals')
          .doc(todayKey)
          .get();

      if (!doc.exists) return 0;

      return (doc.data()?['totalCalories'] ?? 0) as int;
    } catch (e) {
      print('Error getting calories: $e');
      return 0;
    }
  }
}
