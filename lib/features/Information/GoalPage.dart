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
        setState(() => userData = args);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.012,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: screenWidth * 0.085),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.005),

                    // ── العنوان ──
                    Text(
                      "معلومات عنك",
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.006),

                    Text(
                      "اعطنا معومات عنك اكثر",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: Colors.grey,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // ── Progress bar (مكتمل) ──
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

                    SizedBox(height: screenHeight * 0.045),

                    // ── السؤال ──
                    Text(
                      "ما هو هدفك؟",
                      style: TextStyle(
                        fontSize: screenWidth * 0.058,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // ── خيارات الهدف ──
                    ...goals.map(
                      (goal) =>
                          _buildGoalOption(goal, screenWidth, screenHeight),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // ── زرار التالي ──
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.065,
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

                                userData!.goal = selectedGoal!;

                                double bmr = CaloriesCalculator.calculateBMR(
                                  gender: userData!.gender,
                                  age: userData!.age,
                                  height: userData!.height,
                                  weight: userData!.weight,
                                );

                                double dailyCalories =
                                    CaloriesCalculator.calculateDailyCalories(
                                      bmr: bmr,
                                      goal: selectedGoal!,
                                    );

                                userData!.bmr = bmr;
                                userData!.dailyCalories = dailyCalories;

                                try {
                                  final userDataService = UserDataService();
                                  await userDataService.saveUserData(userData!);
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
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.08,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "اقتربنا",
                          style: TextStyle(
                            fontSize: screenWidth * 0.048,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(
    String goal,
    double screenWidth,
    double screenHeight,
  ) {
    final bool isSelected = selectedGoal == goal;

    return GestureDetector(
      onTap: () => setState(() => selectedGoal = goal),
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.015),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.018,
        ),
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
            // ── دايرة الاختيار ──
            Container(
              width: screenWidth * 0.055,
              height: screenWidth * 0.055,
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
                        width: screenWidth * 0.025,
                        height: screenWidth * 0.025,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff6BAF1A),
                        ),
                      ),
                    )
                  : null,
            ),

            // ── النص ──
            Text(
              goal,
              style: TextStyle(
                fontSize: screenWidth * 0.048,
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
