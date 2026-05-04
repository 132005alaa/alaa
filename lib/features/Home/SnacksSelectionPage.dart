import 'package:flutter/material.dart';
import 'package:healthy_food/data/snacks_data.dart';
import 'package:healthy_food/services/notification_service.dart';
import 'package:healthy_food/services/meal_tracking_service.dart';

class SnacksSelectionPage extends StatelessWidget {
  final String mealType;

  const SnacksSelectionPage({super.key, this.mealType = 'التسلية'});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> meals = SnacksData.getSnackMeals();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
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
                      child: const Icon(
                        Icons.chevron_left,
                        size: 30,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        mealType,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),

            // قائمة الوجبات
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: meals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    _SnacksCard(meal: meals[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnacksCard extends StatelessWidget {
  final Map<String, dynamic> meal;

  const _SnacksCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final String name = meal['name'];
    final String portion = meal['portion'] ?? '';
    final int calories = meal['calories'];
    final int protein = meal['protein'];
    final int carbs = meal['carbs'];
    final int fat = meal['fat'];
    final String ingredients = meal['ingredients'];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 340,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // صورة الوجبة
            Image.asset(
              meal['image'],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xffD6EFA0),
                child: const Icon(
                  Icons.restaurant,
                  size: 60,
                  color: Color(0xff6BAF1A),
                ),
              ),
            ),
            // طبقة التعتيم
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

            // المحتوى
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      portion,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ingredients,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffC8E63A).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🔥 $calories سعرة حرارية',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2A3A00),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _nutriLabel(emoji: '🧈', label: 'دهون', value: fat),
                        const SizedBox(width: 16),
                        _nutriLabel(
                          emoji: '🌾',
                          label: 'كربوهيدرات',
                          value: carbs,
                        ),
                        const SizedBox(width: 16),
                        _nutriLabel(
                          emoji: '🟡',
                          label: 'بروتين',
                          value: protein,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                            mealType: 'التسلية', // أو العشاء حسب الصفحة
                            portion: portion,
                          );

                          await NotificationService().addMealReminder(name);
                          await NotificationService()
                              .addMotivationalNotification();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم إضافة $name بنجاح! (+$calories سعرة) 🍎',
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
                          width: 240,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: const Color(0xffC8E63A),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'اضافه الوجبه',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff2A3A00),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.add_circle_outline,
                                color: Color(0xff2A3A00),
                                size: 20,
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
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(width: 4),
        Text(emoji, style: const TextStyle(fontSize: 17)),
      ],
    );
  }
}
