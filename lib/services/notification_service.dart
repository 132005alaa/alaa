import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // جلب جميع إشعارات المستخدم
  Stream<List<NotificationModel>> getNotifications() {
    String userId = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return NotificationModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // جلب عدد الإشعارات غير المقروءة
  Stream<int> getUnreadCount() {
    String userId = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // تحديث حالة الإشعار (مقروء/غير مقروء)
  Future<void> markAsRead(String notificationId) async {
    String userId = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // 🟢 إضافة إشعار عام
  Future<void> addNotification({
    required String title,
    required String subtitle,
    required String emoji,
    required String section,
  }) async {
    String userId = _auth.currentUser!.uid;

    NotificationModel notification = NotificationModel(
      id: '',
      title: title,
      subtitle: subtitle,
      emoji: emoji,
      section: section,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notification.toMap());
  }

  // 🟢 إشعارات تحفيزية متنوعة
  Future<void> addMotivationalNotification() async {
    List<Map<String, String>> motivationalMessages = [
      {
        'title': 'أنت أقوى مما تظن! 💪',
        'subtitle': 'استمر في طريقك الصحي، كل خطوة تقربك من هدفك',
        'emoji': '🌟',
      },
      {
        'title': 'تذكر هدفك',
        'subtitle': 'كل يوم جديد هو فرصة لتكون أفضل نسخة من نفسك',
        'emoji': '🎯',
      },
      {
        'title': 'أنت تستحق الأفضل',
        'subtitle': 'اهتمامك بصحتك هو أعظم استثمار في نفسك',
        'emoji': '💚',
      },
      {
        'title': 'استمر ولا تتوقف',
        'subtitle': 'النجاح ليس محطة، بل رحلة مستمرة من التطور',
        'emoji': '🚀',
      },
    ];

    final message =
        motivationalMessages[DateTime.now().second %
            motivationalMessages.length];

    await addNotification(
      title: message['title']!,
      subtitle: message['subtitle']!,
      emoji: message['emoji']!,
      section: _getSection(DateTime.now()),
    );
  }

  // 🟢 إشعارات شرب الماء
  Future<void> addWaterReminderNotification() async {
    List<Map<String, String>> waterMessages = [
      {
        'title': 'حان وقت شرب الماء 💧',
        'subtitle': 'الماء يساعد على التركيز ويزيد من نشاطك',
        'emoji': '💧',
      },
      {
        'title': 'اشرب كوب ماء الآن! 🥤',
        'subtitle': 'جسمك يحتاج إلى الترطيب المستمر',
        'emoji': '🥤',
      },
      {
        'title': 'لا تنسى شرب الماء 🌊',
        'subtitle': 'كل كوب ماء يساعد في تحسين صحة بشرتك وهضمك',
        'emoji': '🌊',
      },
      {
        'title': 'قف واشرب ماء 🚰',
        'subtitle': 'الحركة وشرب الماء معاً ينشطان الدورة الدموية',
        'emoji': '🚰',
      },
    ];

    final message = waterMessages[DateTime.now().second % waterMessages.length];

    await addNotification(
      title: message['title']!,
      subtitle: message['subtitle']!,
      emoji: message['emoji']!,
      section: _getSection(DateTime.now()),
    );
  }

  // 🟢 إشعارات تذكير بالوجبات
  Future<void> addMealReminder(String mealType) async {
    Map<String, Map<String, String>> mealMessages = {
      'الفطار': {
        'title': 'وقت الإفطار 🌅',
        'subtitle': 'ابدأ يومك بوجبة صحية تمدك بالطاقة',
        'emoji': '🍳',
      },
      'الغداء': {
        'title': 'وقت الغداء 🍽️',
        'subtitle': 'اختر وجبة متوازنة غنية بالبروتين والخضروات',
        'emoji': '🍽️',
      },
      'العشاء': {
        'title': 'وقت العشاء 🌙',
        'subtitle': 'تناول وجبة خفيفة قبل النوم بثلاث ساعات',
        'emoji': '🥗',
      },
      'التسليه': {
        'title': 'وجبة خفيفة 🍎',
        'subtitle': 'حان وقت تناول وجبة صحية خفيفة',
        'emoji': '🍎',
      },
    };

    final message = mealMessages[mealType];
    if (message != null) {
      await addNotification(
        title: message['title']!,
        subtitle: message['subtitle']!,
        emoji: message['emoji']!,
        section: _getSection(DateTime.now()),
      );
    }
  }

  // 🟢 إشعارات التمارين
  Future<void> addWorkoutReminder() async {
    List<Map<String, String>> workoutMessages = [
      {
        'title': 'حان وقت التمرين 🏋️',
        'subtitle': '30 دقيقة من الحركة تغير يومك بالكامل',
        'emoji': '🏋️',
      },
      {
        'title': 'حرك جسمك الآن 🚶',
        'subtitle': 'المشي لمدة 10 دقائق يحسن المزاج والطاقة',
        'emoji': '🚶',
      },
      {
        'title': 'تمرين سريع 🧘',
        'subtitle': 'حتى 5 دقائق من التمدد تحسن مرونة جسمك',
        'emoji': '🧘',
      },
    ];

    final message =
        workoutMessages[DateTime.now().second % workoutMessages.length];

    await addNotification(
      title: message['title']!,
      subtitle: message['subtitle']!,
      emoji: message['emoji']!,
      section: _getSection(DateTime.now()),
    );
  }

  // 🟢 إشعارات تحقيق الأهداف
  Future<void> addGoalAchievementNotification(double progress) async {
    String title = '';
    String subtitle = '';
    String emoji = '';

    if (progress >= 1.0) {
      title = 'مبروك! حققت هدفك اليومي 🎉';
      subtitle = 'أنت رائع! استمر في هذا المستوى';
      emoji = '🏆';
    } else if (progress >= 0.7) {
      title = 'قريب من هدفك! ⭐';
      subtitle = 'أنت على بعد خطوات قليلة، استمر';
      emoji = '⭐';
    } else if (progress >= 0.5) {
      title = 'في منتصف الطريق 🚀';
      subtitle = 'ممتاز! أكمل بنفس الحماس';
      emoji = '🚀';
    } else if (progress >= 0.3) {
      title = 'بداية جيدة 🌱';
      subtitle = 'كل خطوة مهما صغيرة تقربك من هدفك';
      emoji = '🌱';
    } else {
      title = 'ابدأ الآن 💪';
      subtitle = 'لا تؤجل، اليوم هو أفضل يوم للبداية';
      emoji = '💪';
    }

    await addNotification(
      title: title,
      subtitle: subtitle,
      emoji: emoji,
      section: _getSection(DateTime.now()),
    );
  }

  // 🟢 إشعارات عشوائية طوال اليوم (للتحفيز المستمر)
  Future<void> addRandomDailyReminder() async {
    List<Map<String, String>> dailyReminders = [
      {
        'title': 'نصيحة اليوم 💡',
        'subtitle': 'شرب الماء على الريق ينشط الجهاز الهضمي',
        'emoji': '💡',
      },
      {
        'title': 'تذكير 🌿',
        'subtitle': 'الخضروات الورقية مصدر غني بالحديد والفيتامينات',
        'emoji': '🌿',
      },
      {
        'title': 'حقيقة صحية 🧠',
        'subtitle': 'النوم الكافي يساعد على التحكم بالوزن',
        'emoji': '🧠',
      },
      {
        'title': 'تحدي اليوم ⚡',
        'subtitle': 'امشِ 5000 خطوة اليوم وشاركنا',
        'emoji': '⚡',
      },
      {
        'title': 'أطعمة مفيدة 🥑',
        'subtitle': 'الأفوكادو مصدر رائع للدهون الصحية',
        'emoji': '🥑',
      },
    ];

    final reminder = dailyReminders[DateTime.now().day % dailyReminders.length];

    await addNotification(
      title: reminder['title']!,
      subtitle: reminder['subtitle']!,
      emoji: reminder['emoji']!,
      section: _getSection(DateTime.now()),
    );
  }

  // تحديد القسم بناءً على التاريخ
  String _getSection(DateTime date) {
    DateTime now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'اليوم';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'امس';
    } else if (date.isAfter(now.subtract(Duration(days: 7)))) {
      return 'خلال الاسبوع';
    } else {
      return 'الاسبوع الماضي';
    }
  }

  // 🔹 تحديث جميع الإشعارات كـ مقروءة
  Future<void> markAllAsRead() async {
    String userId = _auth.currentUser!.uid;

    var snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
    // 🟢 إشعار إكمال هدف شرب الماء
    // ignore: unused_element
    Future<void> showGoalAchievedNotification() async {
      await addNotification(
        title: '🎉 تهانينا! أكملت هدف شرب الماء',
        subtitle: 'شربت 2500 مل اليوم! حافظ على ترطيب جسمك',
        emoji: '💙',
        section: _getSection(DateTime.now()),
      );
    }
  }

  void showGoalAchievedNotification() {}
}
