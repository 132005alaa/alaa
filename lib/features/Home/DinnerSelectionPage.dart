import 'package:flutter/material.dart';
import 'package:healthy_food/data/dinner_data.dart';
import 'package:healthy_food/services/notification_service.dart';
import 'package:healthy_food/services/meal_tracking_service.dart';

class DinnerSelectionPage extends StatelessWidget {
  final String mealType;
  const DinnerSelectionPage({super.key, this.mealType = 'العشاء'});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> meals = DinnerData.getDinnerMeals();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.018,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        size: screenWidth * 0.07,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        mealType,
                        style: TextStyle(
                          fontSize: screenWidth * 0.058,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.1),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                itemCount: meals.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: screenHeight * 0.018),
                itemBuilder: (context, index) =>
                    _DinnerCard(meal: meals[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DinnerCard extends StatelessWidget {
  final Map<String, dynamic> meal;

  const _DinnerCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final String name = meal['name'];
    final String portion = meal['portion'] ?? '';
    final int calories = meal['calories'];
    final int protein = meal['protein'];
    final int carbs = meal['carbs'];
    final int fat = meal['fat'];
    final String ingredients = meal['ingredients'];
    final cardHeight = screenHeight * 0.38;
    return ClipRRect(
      borderRadius: BorderRadius.circular(screenWidth * 0.055),
      child: SizedBox(
        height: cardHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              meal['image'],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xffD6EFA0),
                child: Icon(
                  Icons.restaurant,
                  size: screenWidth * 0.14,
                  color: const Color(0xff6BAF1A),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xCC000000),
                  ],
                  stops: [0.0, 0.2, 0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 8),
                        ],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: screenHeight * 0.004),
                    Text(
                      portion,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Colors.white70,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      ingredients,
                      style: TextStyle(
                        fontSize: screenWidth * 0.029,
                        color: Colors.white60,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: screenHeight * 0.007),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.004,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffC8E63A).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                      child: Text(
                        '🔥 $calories سعرة حرارية',
                        style: TextStyle(
                          fontSize: screenWidth * 0.034,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff2A3A00),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _nutriLabel(
                          emoji: '🧈',
                          label: 'دهون',
                          value: fat,
                          screenWidth: screenWidth,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        _nutriLabel(
                          emoji: '🌾',
                          label: 'كربوهيدرات',
                          value: carbs,
                          screenWidth: screenWidth,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        _nutriLabel(
                          emoji: '🟡',
                          label: 'بروتين',
                          value: protein,
                          screenWidth: screenWidth,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final mealService = MealTrackingService();
                          await mealService.addMeal(
                            mealName: name,
                            calories: calories,
                            protein: protein,
                            carbs: carbs,
                            fat: fat,
                            mealType: 'العشاء',
                            portion: portion,
                          );
                          await NotificationService().addMealReminder(name);
                          await NotificationService()
                              .addMotivationalNotification();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم إضافة $name بنجاح! (+$calories سعرة) 🌙',
                                  textDirection: TextDirection.rtl,
                                ),
                                backgroundColor: const Color(0xff6BAF1A),
                              ),
                            );
                            Future.delayed(const Duration(seconds: 1), () {
                              if (context.mounted) Navigator.pop(context);
                            });
                          }
                        },
                        child: Container(
                          width: screenWidth * 0.6,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffC8E63A),
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.08,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'اضافه الوجبه',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.038,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff2A3A00),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Icon(
                                Icons.add_circle_outline,
                                color: const Color(0xff2A3A00),
                                size: screenWidth * 0.048,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutriLabel({
    required String emoji,
    required String label,
    required int value,
    required double screenWidth,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: screenWidth * 0.044,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 5)],
          ),
        ),
        SizedBox(width: screenWidth * 0.01),
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.037,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 5)],
          ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(width: screenWidth * 0.01),
        Text(emoji, style: TextStyle(fontSize: screenWidth * 0.04)),
      ],
    );
  }
}
