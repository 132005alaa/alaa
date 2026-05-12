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
      final userDataService = UserDataService();
      UserData? userData = await userDataService.getUserData();
      if (userData != null && userData.dailyCalories != null) {
        setState(() {
          _calories = userData.dailyCalories!.round();
          _goal = userData.goal;
          _isLoading = false;
        });
      } else {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args != null && args is Map<String, dynamic>) {
          setState(() {
            _calories = args['calories'] ?? 0;
            _goal = args['goal'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.04),

                  Text(
                    "تهانينا",
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.008),

                  Text(
                    "! لقد اعدتنا لك نظامك الغذائي",
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.035),

                  SizedBox(
                    width: screenWidth * 0.52,
                    height: screenWidth * 0.52,
                    child: CustomPaint(
                      painter: _CalorieRingPainter(),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "🔥",
                              style: TextStyle(fontSize: screenWidth * 0.07),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              "$_calories",
                              style: TextStyle(
                                fontSize: screenWidth * 0.08,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "يوم / كالوري",
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLegendItem(
                          color: const Color(0xff4A7C2F),
                          label: "دهون",
                          percent: _getFatPercent(),
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                        _buildLegendItem(
                          color: const Color(0xffB5D97A),
                          label: "بروتين",
                          percent: _getProteinPercent(),
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                        _buildLegendItem(
                          color: const Color(0xff7CAF3A),
                          label: "كربوهيدرات",
                          percent: _getCarbsPercent(),
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        screenWidth * 0.06,
                        screenHeight * 0.03,
                        screenWidth * 0.06,
                        screenHeight * 0.035,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xffD6EFA0),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "حافظ علي توازنك",
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff410B0B),
                            ),
                            textDirection: TextDirection.rtl,
                          ),

                          SizedBox(height: screenHeight * 0.01),

                          Text(
                            "التغيير مش في يوم....لكن كل يوم",
                            style: TextStyle(
                              fontSize: screenWidth * 0.048,
                              color: const Color.fromARGB(255, 93, 92, 92),
                            ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          Text(
                            "🌱🌱🌱🌱🌱🌱",
                            style: TextStyle(fontSize: screenWidth * 0.1),
                          ),

                          SizedBox(height: screenHeight * 0.025),

                          // زرار لنبدأ
                          SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.065,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushReplacementNamed(
                                context,
                                '/home',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff6BAF1A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.08,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "لنبدا",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.048,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
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

  String _getFatPercent() {
    if (_goal == 'خسارة وزن') return "(30%)";
    if (_goal == 'زيادة عضلات' || _goal == 'زيادة وزن') return "(25%)";
    return "(30%)";
  }

  String _getProteinPercent() {
    if (_goal == 'خسارة وزن') return "(40%)";
    if (_goal == 'زيادة عضلات' || _goal == 'زيادة وزن') return "(35%)";
    return "(30%)";
  }

  String _getCarbsPercent() {
    if (_goal == 'خسارة وزن') return "(30%)";
    if (_goal == 'زيادة عضلات' || _goal == 'زيادة وزن') return "(40%)";
    return "(40%)";
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String percent,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Column(
      children: [
        Container(
          width: screenWidth * 0.045,
          height: screenWidth * 0.045,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(height: screenHeight * 0.008),
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.038,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          textDirection: TextDirection.rtl,
        ),
        Text(
          percent,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.black54,
          ),
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
