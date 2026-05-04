import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data_model.dart';

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserData(UserData userData) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception("المستخدم مش مسجل دخول");
      }

      await _firestore
          .collection('users')
          .doc(user.uid) // 👈 الصح هنا
          .set(userData.toMap());

      print('✅ تم حفظ البيانات بنجاح');
    } catch (e) {
      print('❌ خطأ في حفظ البيانات: $e');
      rethrow;
    }
  }

  // جلب بيانات المستخدم
  Future<UserData?> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      String userId = user.uid;
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserData.fromMap(doc.data() as Map<String, dynamic>, userId);
      }
      return null;
    } catch (e) {
      print('❌ خطأ في جلب البيانات: $e');
      return null;
    }
  }

  // تحديث بيانات المستخدم
  Future<void> updateUserData(UserData userData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userData.userId)
          .update(userData.toMap());
      print('✅ تم تحديث البيانات بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث البيانات: $e');
      rethrow;
    }
  }
}
