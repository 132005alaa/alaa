import 'package:flutter/material.dart';
import 'package:healthy_food/data/workout_data.dart';
import 'package:healthy_food/services/notification_service.dart';
import 'package:healthy_food/services/workout_tracking_service.dart';

class WorkoutSelectionPage extends StatelessWidget {
  const WorkoutSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> workouts = WorkoutData.getWorkouts();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                  const Expanded(
                    child: Center(
                      child: Text(
                        'التدريب',
                        style: TextStyle(
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
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: workouts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    _WorkoutCard(workout: workouts[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;

  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final String name = workout['name'];
    final String time = workout['time'];
    final String level = workout['level'];
    final int calories = workout['calories'];
    final String target = workout['target'];

    final Color levelColor = level == 'سهل'
        ? const Color(0xff6BAF1A)
        : level == 'متوسط'
        ? const Color(0xffFFCA28)
        : const Color(0xffFF5722);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 340,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              workout['image'],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xffD6EFA0),
                child: const Icon(
                  Icons.fitness_center,
                  size: 60,
                  color: Color(0xff6BAF1A),
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
                      target,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '⏱️ $time',
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
                        '🔥 $calories سعرة محروقة',
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              level,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: levelColor,
                                shadows: const [
                                  Shadow(color: Colors.black54, blurRadius: 5),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'صعوبة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 5),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 5),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'الوقت',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 5),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('⏱️', style: TextStyle(fontSize: 17)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final workoutService = WorkoutTrackingService();

                          await workoutService.addWorkout(
                            workoutName: name,
                            calories: calories,
                            time: time,
                            level: level,
                            target: target,
                          );

                          await NotificationService().addWorkoutReminder();
                          await NotificationService()
                              .addMotivationalNotification();

                          if (context.mounted) {
                            Navigator.pop(context, true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم إضافة $name بنجاح! (+$calories سعرة محروقة) 💪',
                                  textDirection: TextDirection.rtl,
                                ),
                                backgroundColor: const Color(0xff6BAF1A),
                                duration: const Duration(seconds: 2),
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
                                'اضافه التدريب',
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
}
