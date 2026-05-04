import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addWorkout({
    required String workoutName,
    required int calories,
    required String time,
    required String level,
    required String target,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month}-${now.day}';

      final userWorkoutsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc(todayKey);

      final docSnapshot = await userWorkoutsRef.get();

      List<Map<String, dynamic>> workoutsList = [];

      if (docSnapshot.exists) {
        workoutsList = List<Map<String, dynamic>>.from(
          docSnapshot.data()?['workouts'] ?? [],
        );
      }

      workoutsList.add({
        'name': workoutName,
        'calories': calories,
        'time': time,
        'level': level,
        'target': target,
        'timestamp': DateTime.now().toIso8601String(),
      });

      int totalCalories = workoutsList.fold(
        0,
        (sum, workout) => sum + (workout['calories'] as int),
      );

      await userWorkoutsRef.set({
        'date': todayKey,
        'workouts': workoutsList,
        'totalCaloriesBurned': totalCalories,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding workout: $e');
      rethrow;
    }
  }

  Future<int> getTodayWorkoutCalories() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month}-${now.day}';

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc(todayKey)
          .get();

      if (!doc.exists) return 0;

      return (doc.data()?['totalCaloriesBurned'] ?? 0) as int;
    } catch (e) {
      print('Error getting workout calories: $e');
      return 0;
    }
  }

  Stream<int> getTodayWorkoutCaloriesStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .doc(todayKey)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 0;
          return (doc.data()?['totalCaloriesBurned'] ?? 0) as int;
        });
  }
}
