import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/user_data_service.dart';
import '../../models/user_data_model.dart';

class CongratulationsPage extends StatefulWidget {
  const CongratulationsPage({super.key});

  @override
  State<CongratulationsPage> createState() => _CongratulationsPageState();
}

class _CongratulationsPageState extends State<CongratulationsPage> {
  int _calories = 0;
  String _goal = '';
  bool _isLoading = true;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      // جلب البيانات من Firebase
      final userDataService = UserDataService();
      UserData? userData = await userDataService.getUserData();

      if (userData != null && userData.dailyCalories != null) {
        setState(() {
          _calories = userData.dailyCalories!.round();
          _goal = userData.goal;
          _isLoading = false;
        });
      } else {
        // ✅ دلوقتي ModalRoute.of(context) هيشتغل صح لأننا في didChangeDependencies
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args != null && args is Map<String, dynamic>) {
          setState(() {
            _calories = args['calories'] ?? 0;
            _goal = args['goal'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Title
                    const Text(
                      "تهانينا",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "! لقد اعدتنا لك نظامك الغذائي ",
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),

                    const SizedBox(height: 40),

                    // Circular calories chart
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(
                        painter: _CalorieRingPainter(),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("🔥", style: TextStyle(fontSize: 32)),
                              const SizedBox(height: 6),
                              Text(
                                "$_calories",
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Text(
                                "يوم / كالوري",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Legend row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegendItem(
                            color: const Color(0xff4A7C2F),
                            label: "دهون",
                            percent: _getFatPercent(),
                          ),
                          _buildLegendItem(
                            color: const Color(0xffB5D97A),
                            label: "بروتين",
                            percent: _getProteinPercent(),
                          ),
                          _buildLegendItem(
                            color: const Color(0xff7CAF3A),
                            label: "كربوهيدرات",
                            percent: _getCarbsPercent(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Green card at the bottom
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                      decoration: const BoxDecoration(
                        color: Color(0xffD6EFA0),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "حافظ علي توازنك",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff410B0B),
                            ),
                            textDirection: TextDirection.rtl,
                          ),

                          const SizedBox(height: 10),

                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "التغيير مش في يوم....لكن كل يوم",
                              style: TextStyle(
                                fontSize: 23,
                                color: Color.fromARGB(255, 93, 92, 92),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "🌱🌱🌱🌱🌱🌱 ",
                              style: TextStyle(fontSize: 45),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Start button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/home',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff6BAF1A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "لنبدا",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
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

  String _getFatPercent() {
    if (_goal == 'خسارة وزن') {
      return "(30%)";
    } else if (_goal == 'زيادة عضلات' || _goal == 'زيادة وزن') {
      return "(25%)";
    } else {
      return "(30%)";
    }
  }

  String _getProteinPercent() {
    if (_goal == 'خسارة وزن') {
      return "(40%)";
    } else if (_goal == 'زيادة عضلات' || _goal == 'زيادة وزن') {
      return "(35%)";
    } else {
      return "(30%)";
    }
  }

  String _getCarbsPercent() {
    if (_goal == 'خسارة وزن') {
      return "(30%)";
    } else if (_goal == 'زيادة عضلات' || _goal == 'زيادة وزن') {
      return "(40%)";
    } else {
      return "(40%)";
    }
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String percent,
  }) {
    return Column(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          textDirection: TextDirection.rtl,
        ),
        Text(
          percent,
          style: const TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ],
    );
  }
}

class _CalorieRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 22.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final segments = [
      (const Color(0xff4A7C2F), 0.50),
      (const Color(0xffB5D97A), 0.25),
      (const Color(0xff7CAF3A), 0.25),
    ];

    const gapAngle = 0.04;
    const startAngle = -math.pi / 2;
    double currentAngle = startAngle;

    for (final seg in segments) {
      final sweepAngle = seg.$2 * 2 * math.pi - gapAngle;
      paint.color = seg.$1;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        false,
        paint,
      );
      currentAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
