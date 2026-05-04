import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthy_food/services/notification_service.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> with TickerProviderStateMixin {
  final int totalMl = 2500;
  final int stepMl = 200;
  int currentMl = 0;

  late AnimationController _waterController;
  late Animation<double> _waterAnim;
  double _prevWaterLevel = 0;

  late AnimationController _waveController;
  late Animation<double> _waveAnim;

  // مفاتيح التخزين
  static const String _savedMlKey = 'water_current_ml';
  static const String _savedDateKey = 'water_last_date';

  @override
  void initState() {
    super.initState();

    _waterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _waterAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _waterController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _waveAnim = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));

    _loadWaterData();
  }

  @override
  void dispose() {
    _waterController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  // تحميل البيانات المحفوظة
  Future<void> _loadWaterData() async {
    final prefs = await SharedPreferences.getInstance();

    // جلب آخر تاريخ تم تسجيل شرب فيه
    String? lastDateString = prefs.getString(_savedDateKey);
    DateTime? lastDate;

    if (lastDateString != null) {
      lastDate = DateTime.parse(lastDateString);
    }

    final today = DateTime.now();

    // طباعة للتحقق (تقدري تشوفيها في الـ console)
    print('📅 آخر تاريخ مسجل: $lastDate');
    print('📅 تاريخ اليوم: $today');

    // مقارنة التاريخ (سنة، شهر، يوم)
    final isSameDay =
        lastDate != null &&
        lastDate.year == today.year &&
        lastDate.month == today.month &&
        lastDate.day == today.day;

    print('📅 هل هو نفس اليوم؟ $isSameDay');

    int savedMl;

    if (isSameDay) {
      // نفس اليوم: نجيب الكمية المخزنة
      savedMl = prefs.getInt(_savedMlKey) ?? 0;
      print('💾 نفس اليوم، الكمية المحفوظة: $savedMl');
    } else {
      // يوم جديد: نبدأ من الصفر
      savedMl = 0;
      await _saveWaterData(0);
      print('🆕 يوم جديد، نبدأ من 0');
    }

    setState(() {
      currentMl = savedMl.clamp(0, totalMl);
      _prevWaterLevel = currentMl / totalMl;
      _waterAnim = Tween<double>(begin: _prevWaterLevel, end: _prevWaterLevel)
          .animate(
            CurvedAnimation(parent: _waterController, curve: Curves.easeInOut),
          );
    });
  }

  // حفظ البيانات
  Future<void> _saveWaterData(int ml) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_savedMlKey, ml);
    await prefs.setString(_savedDateKey, DateTime.now().toIso8601String());
    print('💾 تم الحفظ: $ml مل في تاريخ ${DateTime.now()}');
  }

  // حفظ الإحصائيات الأسبوعية
  Future<void> _saveWeeklyStats(int ml) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();
    await prefs.setInt('stats_$todayKey', ml);
  }

  // جلب إحصائيات يوم معين
  Future<int> _getDayStats(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = '${date.year}-${date.month}-${date.day}';
    return prefs.getInt('stats_$dateKey') ?? 0;
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  // شرب الماء
  void _drink() {
    if (currentMl >= totalMl) return;

    final wasCompleted = currentMl >= totalMl;

    setState(() {
      _prevWaterLevel = currentMl / totalMl;
      currentMl = (currentMl + stepMl).clamp(0, totalMl);

      _saveWaterData(currentMl); // حفظ فوري
      _saveWeeklyStats(currentMl);

      final newLevel = currentMl / totalMl;

      _waterAnim = Tween<double>(begin: _prevWaterLevel, end: newLevel).animate(
        CurvedAnimation(parent: _waterController, curve: Curves.easeInOut),
      );
      _waterController.forward(from: 0);

      print('💧 تم الشرب: $currentMl مل');

      if (currentMl >= totalMl && !wasCompleted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _showCelebration();
            NotificationService().showGoalAchievedNotification();
          }
        });
      }
    });
  }

  // إعادة تعيين اليوم
  void _resetToday() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين'),
        content: const Text('هل أنت متأكد من إعادة تعيين كمية الماء اليوم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        currentMl = 0;
        _saveWaterData(0);
        _saveWeeklyStats(0);
        _prevWaterLevel = 0;
        _waterAnim = Tween<double>(begin: 0, end: 0).animate(
          CurvedAnimation(parent: _waterController, curve: Curves.easeInOut),
        );
        _waterController.forward(from: 0);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إعادة تعيين الكمية لهذا اليوم')),
      );
    }
  }

  // عرض الإحصائيات الأسبوعية
  void _showWeeklyStats() async {
    final today = DateTime.now();
    final List<Map<String, dynamic>> weekData = [];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final ml = await _getDayStats(date);
      final dayName = _getDayName(date);
      weekData.add({'day': dayName, 'ml': ml, 'date': date});
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                '📊 إحصائيات الأسبوع',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: weekData.length,
                itemBuilder: (context, index) {
                  final data = weekData[index];
                  final percentage = (data['ml'] as int) / totalMl;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: Icon(
                        data['ml'] >= totalMl
                            ? Icons.emoji_events
                            : Icons.water_drop,
                        color: data['ml'] >= totalMl
                            ? Colors.amber
                            : Colors.blue,
                      ),
                      title: Text(
                        data['day'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: LinearProgressIndicator(
                        value: percentage.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(Colors.blue),
                      ),
                      trailing: Text(
                        '${data['ml']} / $totalMl مل',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: data['ml'] >= totalMl
                              ? Colors.green
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(DateTime date) {
    const days = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    return days[date.weekday % 7];
  }

  void _showCelebration() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 14),
              const Text(
                'تهانينا!',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff0D47A1),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'لقد اكملت 100% من شرب الماء',
                style: TextStyle(fontSize: 20, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff1E88E5), Color(0xff0D47A1)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      'حسناً',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = totalMl - currentMl;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffE3F4FC), Color(0xffB8E8F8), Color(0xff90D4F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // الهيدر
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          size: 30,
                          color: Color(0xff0D47A1),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _showWeeklyStats,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bar_chart,
                              size: 22,
                              color: Color(0xff0D47A1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _resetToday,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.refresh,
                              size: 22,
                              color: Color(0xff0D47A1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Text(
                'لترطيب جسمك',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff0D47A1),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'اشرب الماء على دفعات ليحافظ على صحتك ويزيد نشاطك',
                style: TextStyle(fontSize: 18, color: Color(0xff3A7ABF)),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              AnimatedBuilder(
                animation: Listenable.merge([_waterAnim, _waveAnim]),
                builder: (context, child) {
                  return SizedBox(
                    width: 260,
                    height: 260,
                    child: CustomPaint(
                      painter: _WaterGaugePainter(
                        waterLevel: _waterAnim.value,
                        wavePhase: _waveAnim.value,
                        currentMl: currentMl,
                        totalMl: totalMl,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 35),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: _drink,
                  child: Container(
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: currentMl >= totalMl
                          ? const LinearGradient(
                              colors: [Colors.grey, Colors.grey],
                            )
                          : const LinearGradient(
                              colors: [Color(0xff1E88E5), Color(0xff0D47A1)],
                            ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff1E88E5).withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        currentMl >= totalMl
                            ? 'اكتمل الهدف اليومي 🎉'
                            : 'اشرب $stepMl مل 💧',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                currentMl >= totalMl
                    ? 'أحسنت! وصلت للهدف اليومي 🎯'
                    : 'استمر في شرب الماء 💪',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xff0D47A1),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedBuilder(
                        animation: _waterAnim,
                        builder: (context, _) {
                          return LinearProgressIndicator(
                            value: _waterAnim.value,
                            minHeight: 10,
                            backgroundColor: Colors.white.withOpacity(0.4),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xff1E88E5),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentMl >= totalMl
                          ? '🎉 مبروك! أكملت هدف اليوم 🎉'
                          : 'تبقى $remaining مل لتحقيق الهدف اليومي',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xff0D47A1),
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Custom Painter ====================
class _WaterGaugePainter extends CustomPainter {
  final double waterLevel;
  final double wavePhase;
  final int currentMl;
  final int totalMl;

  const _WaterGaugePainter({
    required this.waterLevel,
    required this.wavePhase,
    required this.currentMl,
    required this.totalMl,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius - 4));
    canvas.save();
    canvas.clipPath(circlePath);

    final waterTop = center.dy + radius - (2 * radius * waterLevel);
    final waveHeight = 6.0;

    final waterPath = Path();
    waterPath.moveTo(center.dx - radius, waterTop + waveHeight);

    for (double x = center.dx - radius; x <= center.dx + radius; x += 2) {
      final relX = (x - (center.dx - radius)) / (2 * radius);
      final y =
          waterTop + math.sin(relX * 2 * math.pi + wavePhase) * waveHeight;
      waterPath.lineTo(x, y);
    }

    waterPath.lineTo(center.dx + radius, size.height);
    waterPath.lineTo(center.dx - radius, size.height);
    waterPath.close();

    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xff42A5F5).withOpacity(0.9),
          const Color(0xff1565C0).withOpacity(0.95),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(waterPath, waterPaint);

    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    final bubblePositions = [
      Offset(center.dx - 30, waterTop + 30),
      Offset(center.dx + 20, waterTop + 55),
      Offset(center.dx - 10, waterTop + 75),
      Offset(center.dx + 40, waterTop + 35),
    ];
    for (final b in bubblePositions) {
      if (b.dy > waterTop && b.dy < center.dy + radius) {
        canvas.drawCircle(b, 5, bubblePaint);
        canvas.drawCircle(b + const Offset(12, 15), 3, bubblePaint);
      }
    }

    canvas.restore();

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    const segCount = 13;
    const arcStart = math.pi * 1.15;
    const arcSweep = math.pi * 1.7;
    const segGap = 0.06;
    final segSweep = (arcSweep / segCount) - segGap;
    final outerR = radius + 22;
    final innerR = radius + 6;

    for (int i = 0; i < segCount; i++) {
      final segStart = arcStart + i * (arcSweep / segCount);
      final filled = (i / segCount) < waterLevel;

      final segPaint = Paint()
        ..color = filled
            ? const Color(0xff1E88E5)
            : Colors.white.withOpacity(0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerR - innerR
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (outerR + innerR) / 2),
        segStart + segGap / 2,
        segSweep,
        false,
        segPaint,
      );
    }

    final mlText = TextPainter(
      text: TextSpan(
        text: '$currentMl',
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: Color(0xff0D47A1),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    mlText.paint(canvas, Offset(center.dx - mlText.width / 2, center.dy - 36));

    final subText = TextPainter(
      text: TextSpan(
        text: 'مل / $totalMl مل',
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xff1E88E5),
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    subText.paint(
      canvas,
      Offset(center.dx - subText.width / 2, center.dy + 18),
    );
  }

  @override
  bool shouldRepaint(_WaterGaugePainter old) =>
      old.waterLevel != waterLevel ||
      old.wavePhase != wavePhase ||
      old.currentMl != currentMl;
}
