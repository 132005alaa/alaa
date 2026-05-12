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
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

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
  String? _profileImagePath;
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

  String get _imageKey {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return 'profile_image_$uid';
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_imageKey);
    if (mounted) {
      setState(() => _profileImagePath = path);
    }
  }

  Future<void> _refreshProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_imageKey);

    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    final freshUser = FirebaseAuth.instance.currentUser;

    if (mounted) {
      setState(() {
        _profileImagePath = path;
        if (freshUser != null) {
          _userName =
              freshUser.displayName ??
              freshUser.email?.split('@').first ??
              'مستخدم';
        }
      });
    }
  }

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
            _dailyGoal = (data.dailyCalories ?? 0).toInt();
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTodayCalories() async {
    try {
      final mealService = MealTrackingService();
      final calories = await mealService.getTodayCalories();
      if (mounted) setState(() => _totalCalories = calories);
    } catch (e) {
      print('Error loading calories: $e');
    }
  }

  void _listenToBurnedCalories() {
    _workoutService.getTodayWorkoutCaloriesStream().listen((calories) {
      if (!mounted) return;
      setState(() => _burnedCalories = calories);
    });
  }

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
    _loadProfileImage();
  }

  void _loadUnreadCount() {
    NotificationService().getUnreadCount().listen((count) {
      if (mounted) setState(() => _unreadCount = count);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final heroHeight = screenHeight * 0.28;
    final sectionPadding = screenWidth * 0.05;
    final verticalGap = screenHeight * 0.018;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sectionPadding,
                vertical: screenHeight * 0.014,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      setState(() => notificationOpened = true);
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
                            size: 26,
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
                        style: TextStyle(
                          fontSize: screenWidth * 0.043,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.025),
                      CircleAvatar(
                        radius: screenWidth * 0.058,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            _profileImagePath != null &&
                                File(_profileImagePath!).existsSync()
                            ? FileImage(File(_profileImagePath!))
                            : null,
                        child:
                            _profileImagePath == null ||
                                !File(_profileImagePath!).existsSync()
                            ? Icon(
                                Icons.person,
                                color: const Color(0xff6BAF1A),
                                size: screenWidth * 0.055,
                              )
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                            height: heroHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(days.length, (index) {
                              final isSelected = index == selectedDayIndex;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => selectedDayIndex = index),
                                child: Container(
                                  width: (screenWidth - 24) / 7 - 4,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        days[index]['day']!,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.032,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? const Color(0xff6BAF1A)
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        width: 26,
                                        height: 26,
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
                                              fontSize: screenWidth * 0.03,
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

                    SizedBox(height: verticalGap),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sectionPadding),
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
                                setState(
                                  () => _generateDaysOfWeekFromDate(picked),
                                );
                              }
                            },
                            child: const Icon(
                              Icons.calendar_month,
                              color: Color(0xff6BAF1A),
                              size: 26,
                            ),
                          ),
                          Text(
                            _currentMonth,
                            style: TextStyle(
                              fontSize: screenWidth * 0.052,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: verticalGap),

                    // ── كارد السعرات ──
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: sectionPadding * 1.1,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xffD6EFA0),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.035),
                              child: Container(
                                width: screenWidth * 0.24,
                                height: screenWidth * 0.24,
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
                                      Text(
                                        'الاكل',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.032,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xff2D5A0E),
                                        ),
                                      ),
                                      Text(
                                        '$_dailyGoal',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.048,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xff2D5A0E),
                                        ),
                                      ),
                                      Text(
                                        'سعرة',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.026,
                                          color: const Color(0xff2D5A0E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.035,
                                horizontal: screenWidth * 0.03,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildStatRow(
                                    'الاكل',
                                    '$_totalCalories سعرة',
                                    '🍜',
                                    const Color(0xff8BC34A),
                                    screenWidth,
                                  ),
                                  SizedBox(height: screenHeight * 0.025),
                                  _buildStatRow(
                                    'الحرق',
                                    '$_burnedCalories سعرة',
                                    '🔥',
                                    const Color(0xffFF7043),
                                    screenWidth,
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              width: 8,
                              height: screenWidth * 0.38,
                              decoration: const BoxDecoration(
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
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: verticalGap),

                    // ── كارتا النوم والخطوات ──
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sectionPadding),
                      child: Row(
                        children: [
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
                                if (result == true && mounted) _loadUserData();
                              },
                              child: Container(
                                height: screenHeight * 0.165,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
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
                                      color: const Color(
                                        0xff2D2B6B,
                                      ).withOpacity(0.4),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
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
                                      top: -18,
                                      left: -18,
                                      child: Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.05),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(
                                        screenWidth * 0.035,
                                      ),
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
                                              Text(
                                                'النوم',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.038,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '🌙',
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              userData?.sleepHours != null
                                                  ? userData!.sleepHours!
                                                        .toStringAsFixed(1)
                                                  : '--:--',
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.072,
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
                                              Container(
                                                width: 60,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
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
                                              Text(
                                                'ساعة يومياً',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.027,
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

                          SizedBox(width: screenWidth * 0.03),

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
                                if (result == true && mounted) _loadUserData();
                              },
                              child: Container(
                                height: screenHeight * 0.165,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
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
                                      ).withOpacity(0.4),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      bottom: -20,
                                      left: -20,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.08),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(
                                        screenWidth * 0.035,
                                      ),
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
                                              Text(
                                                'الخطوات',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.038,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '👟',
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.04,
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
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.068,
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
                                              Container(
                                                width: 60,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                ),
                                                child: FractionallySizedBox(
                                                  widthFactor:
                                                      userData?.steps != null
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
                                              Text(
                                                'من 10,000',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.027,
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

                    SizedBox(height: verticalGap),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sectionPadding),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'الطعام',
                          style: TextStyle(
                            fontSize: screenWidth * 0.058,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xffE57373),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: verticalGap * 0.7),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: sectionPadding * 0.8,
                      ),
                      itemCount: meals.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: verticalGap * 0.7),
                      itemBuilder: (context, index) =>
                          _buildMealCard(meals[index], screenWidth),
                    ),

                    SizedBox(height: verticalGap * 1.5),
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
    double screenWidth,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 40,
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
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: const Color(0xff2D5A0E),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: screenWidth * 0.034,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        Text(emoji, style: TextStyle(fontSize: screenWidth * 0.05)),
      ],
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal, double screenWidth) {
    return GestureDetector(
      onTap: () async {
        if (meal['title'] == 'الفطار') {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MealSelectionPage()),
          );
          _loadTodayCalories();
        } else if (meal['title'] == 'الغداء') {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LunchSelectionPage()),
          );
          _loadTodayCalories();
        } else if (meal['title'] == 'العشاء') {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DinnerSelectionPage()),
          );
          _loadTodayCalories();
        } else if (meal['title'] == 'التسليه') {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SnacksSelectionPage()),
          );
          _loadTodayCalories();
        } else if (meal['title'] == 'التدريب') {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkoutSelectionPage()),
          );
          _loadTodayCalories();
        }
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.028),
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
                width: screenWidth * 0.185,
                height: screenWidth * 0.185,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: screenWidth * 0.185,
                  height: screenWidth * 0.185,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.restaurant, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.038),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    meal['title'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.052,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2D5A0E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal['subtitle'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.034,
                      color: Colors.black54,
                    ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.068;

    final navItems = [
      {'icon': Icons.home_filled, 'index': 0, 'page': null},
      {'icon': Icons.bar_chart_outlined, 'index': 1, 'page': 'analysis'},
      {'icon': Icons.water_drop_outlined, 'index': 2, 'page': 'water'},
      {'icon': Icons.info_outlined, 'index': 3, 'page': 'info'},
      {'icon': Icons.person_outline, 'index': 4, 'page': 'settings'},
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(
        screenWidth * 0.04,
        0,
        screenWidth * 0.04,
        screenWidth * 0.038,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.028,
      ),
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
        children: navItems.map((item) {
          final idx = item['index'] as int;
          final isActive = currentIndex == idx;
          return GestureDetector(
            onTap: () async {
              setState(() => currentIndex = idx);
              switch (item['page']) {
                case 'analysis':
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnalysisPage(
                        sleepHours: userData?.sleepHours,
                        steps: userData?.steps,
                        calories: _totalCalories,
                        burnedCalories: _burnedCalories,
                        dailyGoal: _dailyGoal,
                      ),
                    ),
                  );
                  break;
                case 'water':
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WaterPage()),
                  );
                  break;
                case 'info':
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InfoTipsPage()),
                  );
                  break;
                case 'settings':
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                  await _refreshProfileData();
                  break;
              }
              if (mounted) setState(() => currentIndex = 0);
            },
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.022),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xffD6EFA0) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'] as IconData,
                color: isActive ? const Color(0xff6BAF1A) : Colors.black54,
                size: iconSize,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
