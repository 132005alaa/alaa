import 'package:flutter/material.dart';
import '../../models/user_data_model.dart';
import '../../utils/calories_calculator.dart';
import '../../services/user_data_service.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  String? selectedGoal;
  UserData? userData;

  final List<String> goals = [
    "خسارة وزن",
    "زيادة وزن",
    "تثبيت الجسم",
    "زيادة عضلات",
  ];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (userData == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is UserData) {
        setState(() {
          userData = args;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back arrow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 35),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 3),

                    // Title
                    const Text(
                      "معلومات عنك",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "اعطنا معومات عنك اكثر",
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    // Progress bar — step 2 of 3 (green covers more)
                    Row(
                      children: [
                        Expanded(
                          flex: 120,
                          child: Container(
                            height: 4,
                            color: const Color(0xffB7D957),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 4,
                            color: const Color(0xffE0E0E0),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // Question
                    const Text(
                      "ما هو هدفك؟",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Goal options
                    ...goals.map((goal) => _buildGoalOption(goal)),

                    const SizedBox(height: 60),

                    // Button: Next → CongratulationsPage
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: selectedGoal != null
                            ? () async {
                                if (userData == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('حدث خطأ، حاول مرة أخرى'),
                                    ),
                                  );
                                  return;
                                }

                                // تحديث الهدف في كائن المستخدم
                                userData!.goal = selectedGoal!;

                                // حساب الـ BMR
                                double bmr = CaloriesCalculator.calculateBMR(
                                  gender: userData!.gender,
                                  age: userData!.age,
                                  height: userData!.height,
                                  weight: userData!.weight,
                                );

                                // حساب السعرات اليومية حسب الهدف
                                double dailyCalories =
                                    CaloriesCalculator.calculateDailyCalories(
                                      bmr: bmr,
                                      goal: selectedGoal!,
                                    );

                                // حفظ القيم المحسوبة
                                userData!.bmr = bmr;
                                userData!.dailyCalories = dailyCalories;

                                // حفظ البيانات في Firebase
                                try {
                                  final userDataService = UserDataService();
                                  await userDataService.saveUserData(userData!);

                                  // التنقل لصفحة النتيجة مع تمرير السعرات
                                  Navigator.pushNamed(
                                    context,
                                    '/congrats',
                                    arguments: {
                                      'calories': dailyCalories.round(),
                                      'goal': selectedGoal,
                                    },
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('خطأ في حفظ البيانات: $e'),
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffB7D957),
                          disabledBackgroundColor: const Color(0xffB7D957),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "اقتربنا",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
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

  Widget _buildGoalOption(String goal) {
    final bool isSelected = selectedGoal == goal;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = goal;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: const Color(0xff6BAF1A), width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xff6BAF1A)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff6BAF1A),
                        ),
                      ),
                    )
                  : null,
            ),
            Text(
              goal,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xff6BAF1A) : Colors.black87,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
