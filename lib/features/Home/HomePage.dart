import 'package:flutter/material.dart';
import 'package:healthy_food/features/navBar/Notifications/NotificationsPage.dart';
import 'package:healthy_food/features/navBar/Informations/InfoTipsPage.dart';
import 'package:healthy_food/features/navBar/setting/SettingsPage.dart';
import 'package:healthy_food/features/navBar/water/WaterPage.dart';
import 'package:healthy_food/features/navBar/Analysis/AnalysisPage.dart';
import 'package:healthy_food/features/Home/MealSelectionPage.dart';
import 'package:healthy_food/features/Home/LunchSelectionPage.dart';
import 'package:healthy_food/features/Home/DinnerSelectionPage.dart';
import 'package:healthy_food/features/Home/SnacksSelectionPage.dart';
import 'package:healthy_food/features/Home/WorkoutSelectionPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthy_food/services/workout_tracking_service.dart';
import '../../models/user_data_model.dart';
import '../../services/user_data_service.dart';
import 'package:healthy_food/services/notification_service.dart';
import 'package:healthy_food/features/profile/SleepInputPage.dart';
import 'package:healthy_food/features/profile/StepsInputPage.dart';
import 'package:healthy_food/services/meal_tracking_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedDayIndex = 3;
  int currentIndex = 0;
  bool notificationOpened = false;
  UserData? userData;
  bool _isLoading = true;
  String _userName = '';
  int _unreadCount = 0;
  int _totalCalories = 0;
  int _dailyGoal = 0;
  int _burnedCalories = 0;
  final WorkoutTrackingService _workoutService = WorkoutTrackingService();

  List<Map<String, String>> days = [];
  String _currentMonth = '';
  final List<Map<String, dynamic>> meals = [
    {
      'title': 'الفطار',
      'subtitle': 'اختر طبقك الذي اعدته بعنايه',
      'image':
          'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=200',
    },
    {
      'title': 'الغداء',
      'subtitle': 'اختر طبقك الذي اعدته بعنايه',
      'image':
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=200',
    },
    {
      'title': 'العشاء',
      'subtitle': 'اختر طبقك الذي اعدته بعنايه',
      'image':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=200',
    },
    {
      'title': 'التسليه',
      'subtitle': 'اختر طبقك الذي اعدته بعنايه',
      'image':
          'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=200',
    },
    {
      'title': 'التدريب',
      'subtitle': 'اختر تمرينك',
      'image':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200',
    },
  ];
  // جلب بيانات المستخدم من Firebase
  Future<void> _loadUserData() async {
    try {
      final userDataService = UserDataService();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        setState(() {
          _userName =
              user.displayName ?? user.email?.split('@').first ?? 'مستخدم';
        });

        UserData? data = await userDataService.getUserData();
        if (data != null) {
          setState(() {
            userData = data;
            _dailyGoal = (data.dailyCalories ?? 0).toInt(); // 👈 مهم
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTodayCalories() async {
    try {
      final mealService = MealTrackingService();
      final calories = await mealService.getTodayCalories();
      setState(() {
        _totalCalories = calories;
      });
    } catch (e) {
      print('Error loading calories: $e');
    }
  }

  void _listenToBurnedCalories() {
    _workoutService.getTodayWorkoutCaloriesStream().listen((calories) {
      if (!mounted) return;

      setState(() {
        _burnedCalories = calories;
      });
    });
  }

  // توليد أيام الأسبوع
  void _generateDaysOfWeek() {
    DateTime now = DateTime.now();
    _currentMonth = _getMonthName(now.month);

    DateTime today = DateTime(now.year, now.month, now.day);
    int weekday = today.weekday;
    DateTime startOfWeek = today.subtract(Duration(days: weekday - 1));

    List<String> dayNames = [
      'أحد',
      'إثنين',
      'ثلاثاء',
      'أربعاء',
      'خميس',
      'جمعة',
      'سبت',
    ];

    days = [];
    for (int i = 0; i < 7; i++) {
      DateTime currentDay = startOfWeek.add(Duration(days: i));
      days.add({
        'day': dayNames[currentDay.weekday - 1],
        'num': currentDay.day.toString(),
        'fullDate': currentDay.toIso8601String(),
      });
    }

    for (int i = 0; i < days.length; i++) {
      DateTime dayDate = DateTime.parse(days[i]['fullDate']!);
      if (dayDate.year == today.year &&
          dayDate.month == today.month &&
          dayDate.day == today.day) {
        selectedDayIndex = i;
        break;
      }
    }
  }

  void _generateDaysOfWeekFromDate(DateTime selectedDate) {
    _currentMonth = _getMonthName(selectedDate.month);

    int weekday = selectedDate.weekday;
    DateTime startOfWeek = selectedDate.subtract(Duration(days: weekday - 1));

    List<String> dayNames = [
      'أحد',
      'إثنين',
      'ثلاثاء',
      'أربعاء',
      'خميس',
      'جمعة',
      'سبت',
    ];

    days = [];
    for (int i = 0; i < 7; i++) {
      DateTime currentDay = startOfWeek.add(Duration(days: i));
      days.add({
        'day': dayNames[currentDay.weekday - 1],
        'num': currentDay.day.toString(),
        'fullDate': currentDay.toIso8601String(),
      });
    }

    for (int i = 0; i < days.length; i++) {
      DateTime dayDate = DateTime.parse(days[i]['fullDate']!);
      if (dayDate.year == selectedDate.year &&
          dayDate.month == selectedDate.month &&
          dayDate.day == selectedDate.day) {
        selectedDayIndex = i;
        break;
      }
    }

    setState(() {});
  }

  // تحويل رقم الشهر لاسم عربي
  String _getMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month - 1];
  }

  @override
  void initState() {
    super.initState();
    _generateDaysOfWeek();
    _loadUserData();
    _loadUnreadCount();
    _loadTodayCalories();
    _listenToBurnedCalories();
  }

  void _loadUnreadCount() {
    NotificationService().getUnreadCount().listen((count) {
      setState(() {
        _unreadCount = count;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header — fixed, NOT scrollable ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      setState(() => notificationOpened = true);

                      // 👈 نخلي كل الإشعارات مقروءة قبل الانتقال
                      await NotificationService().markAllAsRead();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      ).then((_) => setState(() => notificationOpened = false));
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            notificationOpened
                                ? Icons.notifications
                                : Icons.notifications_outlined,
                            size: 28,
                          ),
                        ),
                        if (_unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                '$_unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _isLoading
                            ? 'جاري التحميل...'
                            : 'صباح الخير، $_userName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Everything below scrolls ──
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // ── Hero image with days ──
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
                            height: 280,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(days.length, (index) {
                              final isSelected = index == selectedDayIndex;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => selectedDayIndex = index),
                                child: Container(
                                  width: 46,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        days[index]['day']!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? const Color(0xff6BAF1A)
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xff6BAF1A)
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            days[index]['num']!,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Month row ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() {
                                  _generateDaysOfWeekFromDate(picked);
                                });
                              }
                            },

                            child: Icon(
                              Icons.calendar_month,
                              color: const Color(0xff6BAF1A),
                              size: 28,
                            ),
                          ),
                          Text(
                            _currentMonth,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // الكارد بتاع السعرات
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xffD6EFA0),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Container(
                                width: 115,
                                height: 115,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 3,
                                  ),
                                  color: const Color(0xffD6EFA0),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'الاكل',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff2D5A0E),
                                        ),
                                      ),
                                      Text(
                                        '$_dailyGoal',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff2D5A0E),
                                        ),
                                      ),
                                      const Text(
                                        'سعرة',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xff2D5A0E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildStatRow(
                                    'الاكل',
                                    '$_totalCalories سعرة',
                                    '🍜',
                                    const Color(0xff8BC34A),
                                  ),
                                  const SizedBox(height: 26),
                                  _buildStatRow(
                                    'الحرق',
                                    '$_burnedCalories سعرة',
                                    '🔥',
                                    const Color(0xffFF7043),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 8,
                              height: 115,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xff8BC34A),
                                      Color(0xffFF7043),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    //  كارتا النوم والخطوات
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // ── كارد النوم ──
                          // ── كارد النوم ──
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SleepInputPage(),
                                  ),
                                );
                                if (result == true && mounted) {
                                  _loadUserData();
                                }
                              },
                              child: Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xff1A1A4E),
                                      Color(0xff2D2B6B),
                                      Color(0xff4A3F8C),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(
                                        0xff2D2B6B,
                                      ).withOpacity(0.45),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // النجوم الزخرفية (سيبيها زي ما هي)
                                    Positioned(
                                      top: 10,
                                      left: 14,
                                      child: Text(
                                        '✦',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 28,
                                      left: 30,
                                      child: Text(
                                        '·',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 14,
                                      left: 48,
                                      child: Text(
                                        '✦',
                                        style: TextStyle(
                                          fontSize: 5,
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -18,
                                      left: -18,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.05),
                                        ),
                                      ),
                                    ),

                                    // المحتوى
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text(
                                                'النوم',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Text(
                                                  '🌙',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              userData?.sleepHours != null
                                                  ? '${userData!.sleepHours!.toStringAsFixed(1)}'
                                                  : '--:--',
                                              style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                                height: 1,
                                              ),
                                            ),
                                          ),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 70,
                                                    height: 5,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                    ),
                                                    child: FractionallySizedBox(
                                                      widthFactor:
                                                          userData?.sleepHours !=
                                                              null
                                                          ? (userData!.sleepHours! /
                                                                    8)
                                                                .clamp(0.0, 1.0)
                                                          : 0.0,
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                          color: const Color(
                                                            0xffA78BFA,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Text(
                                                'ساعة يومياً',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white60,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // ── كارد الخطوات ──
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const StepsInputPage(),
                                  ),
                                );
                                if (result == true && mounted) {
                                  _loadUserData();
                                }
                              },
                              child: Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xffFF8C42),
                                      Color(0xffFF6B1A),
                                      Color(0xffE8450A),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xffFF6B1A,
                                      ).withOpacity(0.45),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // دوائر زخرفية
                                    Positioned(
                                      bottom: -20,
                                      left: -20,
                                      child: Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.08),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 30,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.06),
                                        ),
                                      ),
                                    ),

                                    // المحتوى
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text(
                                                'الخطوات',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Text(
                                                  '👟',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              userData?.steps != null
                                                  ? '${userData!.steps}'
                                                  : '0',
                                              style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                                height: 1,
                                              ),
                                            ),
                                          ),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 70,
                                                    height: 5,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                    ),
                                                    child: FractionallySizedBox(
                                                      widthFactor:
                                                          userData?.steps !=
                                                              null
                                                          ? (userData!.steps! /
                                                                    10000)
                                                                .clamp(0.0, 1.0)
                                                          : 0.0,
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Text(
                                                'من 10,000',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'الطعام',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffE57373),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: meals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildMealCard(meals[index]),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    String emoji,
    Color barColor,
  ) {
    // حساب نسبة التقدم حسب الهدف

    // ignore: unused_local_variable
    double progress = 0.0;
    if (label == 'الاكل' && userData != null) {
      // هنا تقدري تحسبي نسبة الأكل بناءً على السعرات المتناولة
      // مؤقتاً هنخليها صفر
      progress = 0.0;
    } else if (label == 'الحرق' && userData != null) {
      progress = 0.0;
    }

    return Row(
      children: [
        Container(
          width: 4,
          height: 42,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff2D5A0E),
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(width: 6),
        Text(emoji, style: const TextStyle(fontSize: 22)),
      ],
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    return GestureDetector(
      onTap: () async {
        if (meal['title'] == 'الفطار') {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MealSelectionPage()),
          );
          _loadTodayCalories();
        }

        if (meal['title'] == 'الغداء') {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LunchSelectionPage()),
          );
          _loadTodayCalories();
        }
        if (meal['title'] == 'العشاء') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DinnerSelectionPage(),
            ),
          );
          _loadTodayCalories();
        }
        if (meal['title'] == 'التسليه') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SnacksSelectionPage(),
            ),
          );
          _loadTodayCalories();
        }
        if (meal['title'] == 'التدريب') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WorkoutSelectionPage(),
            ),
          );
          _loadTodayCalories();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffEEF7CC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                meal['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.restaurant, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    meal['title'],
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2D5A0E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal['subtitle'],
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home - active
          GestureDetector(
            onTap: () => setState(() => currentIndex = 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: currentIndex == 0
                    ? const Color(0xffD6EFA0)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_filled,
                color: currentIndex == 0
                    ? const Color(0xff6BAF1A)
                    : Colors.black54,
                size: 30,
              ),
            ),
          ),
          // Chart icon → AnalysisPage
          // Chart icon → AnalysisPage (مع تمرير البيانات)
          GestureDetector(
            onTap: () {
              setState(() => currentIndex = 1);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalysisPage(
                    sleepHours: userData?.sleepHours,
                    steps: userData?.steps,
                    calories: _totalCalories,
                    burnedCalories: _burnedCalories,
                    dailyGoal: _dailyGoal,
                    // protein: _totalProtein,  // لو عندك بروتين مستقبلاً
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: currentIndex == 1
                    ? const Color(0xffD6EFA0)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_outlined,
                color: currentIndex == 1
                    ? const Color(0xff6BAF1A)
                    : Colors.black54,
                size: 30,
              ),
            ),
          ), // Water icon
          GestureDetector(
            onTap: () {
              setState(() => currentIndex = 2);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WaterPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: currentIndex == 2
                    ? const Color(0xffD6EFA0)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.water_drop_outlined,
                color: currentIndex == 2
                    ? const Color(0xff6BAF1A)
                    : Colors.black54,
                size: 30,
              ),
            ),
          ),
          // Info icon navigates to InfoTipsPage
          GestureDetector(
            onTap: () {
              setState(() => currentIndex = 3);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoTipsPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: currentIndex == 3
                    ? const Color(0xffD6EFA0)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outlined,
                color: currentIndex == 3
                    ? const Color(0xff6BAF1A)
                    : Colors.black54,
                size: 30,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: const Icon(
                Icons.person_outline,
                size: 30,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
