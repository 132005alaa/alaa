import 'package:flutter/material.dart';

class AnalysisPage extends StatelessWidget {
  // متغيرات لاستقبال البيانات من HomePage
  final double? sleepHours;
  final int? steps;
  final int? calories;
  final int? burnedCalories;
  final int? dailyGoal;
  final double? protein;

  const AnalysisPage({
    super.key,
    this.sleepHours,
    this.steps,
    this.calories,
    this.burnedCalories,
    this.dailyGoal,
    this.protein,
  });

  @override
  Widget build(BuildContext context) {
    // استخدام القيم المرسلة أو قيم افتراضية
    final actualSleep = sleepHours ?? 0.0;
    final actualSteps = steps ?? 0;
    final actualCalories = calories ?? 0;
    final actualBurned = burnedCalories ?? 0;
    final actualProtein = protein ?? 0;

    // حساب الطاقة (0-10)
    final energy = _calculateEnergy(
      sleep: actualSleep,
      steps: actualSteps,
      calories: actualCalories,
      protein: actualProtein,
    );

    // تحليل سبب انخفاض الطاقة
    final lowEnergyReason = _getLowEnergyReason(
      energy: energy,
      sleep: actualSleep,
      steps: actualSteps,
      calories: actualCalories,
      protein: actualProtein,
    );

    // نصيحة مخصصة
    final advice = _getAdvice(
      energy: energy,
      sleep: actualSleep,
      steps: actualSteps,
      calories: actualCalories,
      protein: actualProtein,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xffF0F7E6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        size: 30,
                        color: Color(0xff4A7C2F),
                      ),
                    ),
                  ),
                  const Text(
                    'تحليل اليوم',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ── Scrollable Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Column(
                  children: [
                    // ── Card 1: ملخص اليوم بالبيانات الحقيقية ──
                    _sectionCard(
                      topColor: const Color(0xffF6FBF0),
                      borderColor: const Color(0xffD0EAA0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text(
                                'ملخص اليوم',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff2D5A0E),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('⛅', style: TextStyle(fontSize: 25)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'طاقتك اليوم: ${energy.toStringAsFixed(1)} / 10',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 10),
                              _buildBattery(level: energy / 10),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xffDDEEC8)),
                          const SizedBox(height: 10),
                          _buildBullet(
                            color: energy < 5
                                ? Colors.red
                                : const Color(0xffFF6B35),
                            text: lowEnergyReason,
                            bold: true,
                          ),
                          const SizedBox(height: 8),
                          _buildBullet(
                            color: const Color(0xff6BAF1A),
                            text: advice,
                            bold: false,
                            textColor: Colors.black,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Card 2: مخطط النوم ──
                    _sectionCard(
                      topColor: const Color(0xffF6FBF0),
                      borderColor: const Color(0xffD0EAA0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text(
                                'مخطط النوم',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('💪', style: TextStyle(fontSize: 25)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 180,
                            child: CustomPaint(
                              painter: _SleepChartPainter(
                                currentSleep: actualSleep,
                              ),
                              size: const Size(double.infinity, 180),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xff2979FF),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'نمت ${actualSleep.toStringAsFixed(1)} ساعات',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Card 3: إحصائيات اليوم بالبيانات الحقيقية ──
                    _sectionCard(
                      topColor: const Color(0xffF6FBF0),
                      borderColor: const Color(0xffD0EAA0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text(
                                'إحصائيات اليوم',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('📊', style: TextStyle(fontSize: 25)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              // Calories eaten 🍜
                              Expanded(
                                child: _statCard(
                                  label: 'السعرات',
                                  value: actualCalories.toString(),
                                  unit: 'كالوري',
                                  emoji: '🍜',
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xffFF8A65),
                                      Color(0xffFF5722),
                                    ],
                                  ),
                                  textColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Burned Calories 🔥
                              Expanded(
                                child: _statCard(
                                  label: 'الحرق',
                                  value: actualBurned.toString(),
                                  unit: 'كالوري',
                                  emoji: '🔥',
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xffFFCA28),
                                      Color(0xffF57F17),
                                    ],
                                  ),
                                  textColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Steps 👣
                              Expanded(
                                child: _statCard(
                                  label: 'الخطوات',
                                  value: actualSteps.toString(),
                                  unit: 'خطوة',
                                  emoji: '👟',
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xff42A5F5),
                                      Color(0xff1565C0),
                                    ],
                                  ),
                                  textColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Sleep 🌙
                              Expanded(
                                child: _statCard(
                                  label: 'النوم',
                                  value: actualSleep.toStringAsFixed(1),
                                  unit: 'ساعة',
                                  emoji: '🌙',
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xff7E57C2),
                                      Color(0xff311B92),
                                    ],
                                  ),
                                  textColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          // صافي السعرات (الأكل - الحرق)
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xffD0EAA0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'صافي السعرات: ${(actualCalories - actualBurned).abs()} سعرة',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: actualCalories > actualBurned
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                ),
                                Icon(
                                  actualCalories > actualBurned
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: actualCalories > actualBurned
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Card 4: توصيات صحية مخصصة ──
                    _sectionCard(
                      topColor: const Color(0xffF6FBF0),
                      borderColor: const Color(0xffD0EAA0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text(
                                'توصيات صحية',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('🌿', style: TextStyle(fontSize: 25)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ..._getDynamicRecommendations(
                            sleep: actualSleep,
                            steps: actualSteps,
                            calories: actualCalories,
                            burned: actualBurned,
                            protein: actualProtein,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── حساب الطاقة ──
  double _calculateEnergy({
    required double sleep,
    required int steps,
    required int calories,
    required double protein,
  }) {
    double energy = 0;

    // النوم (أقصى 4 نقاط)
    if (sleep >= 8)
      energy += 4;
    else if (sleep >= 7)
      energy += 3;
    else if (sleep >= 6)
      energy += 2;
    else if (sleep >= 5)
      energy += 1;
    else
      energy += 0.5;

    // الخطوات (أقصى 3 نقاط)
    if (steps >= 10000)
      energy += 3;
    else if (steps >= 7000)
      energy += 2;
    else if (steps >= 4000)
      energy += 1;
    else
      energy += 0.5;

    // التغذية (أقصى 3 نقاط)
    if (calories >= 1800 && calories <= 2500)
      energy += 2;
    else if (calories > 2500)
      energy += 1;
    else if (calories < 1200)
      energy += 0.5;
    else
      energy += 1.5;

    // بروتين
    if (protein >= 60)
      energy += 1;
    else if (protein >= 40)
      energy += 0.5;

    return energy.clamp(0.0, 10.0);
  }

  // ── سبب انخفاض الطاقة ──
  String _getLowEnergyReason({
    required double energy,
    required double sleep,
    required int steps,
    required int calories,
    required double protein,
  }) {
    if (energy >= 7) return "طاقتك ممتازة اليوم! 🎉";

    if (sleep < 6) {
      return "السبب: قلة النوم (نميت ${sleep.toStringAsFixed(1)} ساعات فقط)";
    }
    if (steps < 5000) {
      return "السبب: قلة الحركة ($steps خطوة فقط)";
    }
    if (calories < 1500) {
      return "السبب: سعرات حرارية غير كافية";
    }
    if (protein < 40) {
      return "السبب: نقص البروتين في وجباتك";
    }
    return "السبب: يحتاج جسمك للراحة والتوازن";
  }

  // ── نصيحة مخصصة ──
  String _getAdvice({
    required double energy,
    required double sleep,
    required int steps,
    required int calories,
    required double protein,
  }) {
    if (energy >= 8) {
      return "أحسنت! واصل بهذا الروتين اليومي";
    }

    if (sleep < 7) {
      return "النصيحة: حاول النوم 7-8 ساعات الليلة";
    }
    if (steps < 6000) {
      return "النصيحة: امشِ 30 دقيقة إضافية يومياً";
    }
    if (calories < 1600) {
      return "النصيحة: أضف وجبة خفيفة صحية خلال اليوم";
    }
    if (protein < 50) {
      return "النصيحة: أضف بروتين لوجبة الغداء (بيض، دجاج، عدس)";
    }
    if (dailyGoal != null && calories > dailyGoal!) {
      return "النصيحة: حاول تقليل السعرات قليلاً لتحقيق هدفك";
    }

    return "النصيحة: تناول 2 لتر ماء ومارس تمارين التنفس";
  }

  // ── توصيات ديناميكية ──
  List<Widget> _getDynamicRecommendations({
    required double sleep,
    required int steps,
    required int calories,
    required int burned,
    required double protein,
  }) {
    List<Widget> recommendations = [];

    if (sleep < 7) {
      recommendations.add(
        _buildRecommendation('😴', 'نم مبكراً الليلة لتحسين طاقتك'),
      );
    }
    if (steps < 8000) {
      recommendations.add(
        _buildRecommendation('🚶', 'زد خطواتك إلى 8000 خطوة يومياً'),
      );
    }
    if (calories < 1800) {
      recommendations.add(
        _buildRecommendation('🍎', 'أضف وجبة خفيفة صحية بين الوجبات'),
      );
    }
    if (dailyGoal != null && calories > dailyGoal!) {
      recommendations.add(
        _buildRecommendation('⚖️', 'حاول تقليل 200 سعرة من وجباتك'),
      );
    }
    if (protein < 50) {
      recommendations.add(
        _buildRecommendation('🥚', 'تناول 20g إضافية من البروتين اليوم'),
      );
    }
    if (calories - burned > 500) {
      recommendations.add(
        _buildRecommendation('🏃', 'زد حرقك بـ 30 دقيقة مشي إضافية'),
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        _buildRecommendation('🎉', 'أداء رائع! حافظ على هذا المستوى'),
      );
    }

    return recommendations.take(3).toList();
  }

  // ── Section card ──
  Widget _sectionCard({
    required Widget child,
    required Color topColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: topColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff6BAF1A).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── Stat card with gradient background ──
  Widget _statCard({
    required String label,
    required String value,
    required String unit,
    required String emoji,
    required Gradient gradient,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 25)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 18,
              color: textColor.withOpacity(0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: textColor.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ── Battery Widget ──
  Widget _buildBattery({required double level}) {
    return Container(
      width: 44,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Row(
                children: List.generate(
                  4,
                  (i) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: i < (level * 4).round()
                            ? (i == 0
                                  ? Colors.red
                                  : i == 1
                                  ? Colors.orange
                                  : const Color(0xff6BAF1A))
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 3,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bullet point ──
  Widget _buildBullet({
    required Color color,
    required String text,
    required bool bold,
    Color? textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: textColor ?? Colors.black87,
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ],
    );
  }

  // ── Recommendation item ──
  Widget _buildRecommendation(String emoji, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffD0EAA0), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(width: 10),
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xff6BAF1A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

// ── مخطط النوم ──
class _SleepChartPainter extends CustomPainter {
  final double currentSleep;

  _SleepChartPainter({required this.currentSleep});

  @override
  void paint(Canvas canvas, Size size) {
    // حساب موقع الشريط بناءً على ساعات النوم
    final maxSleep = 12.0;
    final minSleep = 0.0;
    final chartHeight = size.height - 60;
    final sleepRatio = (currentSleep - minSleep) / (maxSleep - minSleep);
    final sleepY = size.height - 30 - (sleepRatio * chartHeight);

    // رسم الشريط الأزرق
    final paint = Paint()
      ..color = const Color(0xff2979FF)
      ..style = PaintingStyle.fill;

    final barWidth = size.width * 0.6;
    final barX = (size.width - barWidth) / 2;
    final barHeight = 20.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, sleepY - barHeight, barWidth, barHeight),
        const Radius.circular(10),
      ),
      paint,
    );

    // رسم النص (عدد ساعات النوم)
    final textPainter1 = TextPainter(
      text: TextSpan(
        text: 'نمبت ${currentSleep.toStringAsFixed(1)} ساعات',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xff2979FF),
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    textPainter1.layout();
    textPainter1.paint(
      canvas,
      Offset((size.width - textPainter1.width) / 2, sleepY - 35),
    );

    // رسم خط الهدف (8 ساعات)
    final targetSleep = 8.0;
    final targetRatio = (targetSleep - minSleep) / (maxSleep - minSleep);
    final targetY = size.height - 30 - (targetRatio * chartHeight);

    final dashPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5;

    double dashX = 20;
    while (dashX < size.width - 20) {
      canvas.drawLine(
        Offset(dashX, targetY),
        Offset(dashX + 8, targetY),
        dashPaint,
      );
      dashX += 20;
    }

    // رسم النص (الهدف)
    final textPainter2 = TextPainter(
      text: const TextSpan(
        text: 'الهدف 8 ساعات',
        style: TextStyle(fontSize: 11, color: Colors.grey),
      ),
      textDirection: TextDirection.rtl,
    );
    textPainter2.layout();
    textPainter2.paint(canvas, Offset(20, targetY - 16));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _SleepChartPainter) {
      return oldDelegate.currentSleep != currentSleep;
    }
    return true;
  }
}
