import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_data_service.dart';
import '../../models/user_data_model.dart';

class StepsInputPage extends StatefulWidget {
  const StepsInputPage({super.key});

  @override
  State<StepsInputPage> createState() => _StepsInputPageState();
}

class _StepsInputPageState extends State<StepsInputPage> {
  double _hours = 1.0;
  bool _isSaving = false;

  // حساب الكيلومترات (1 ساعة = 5 كم)
  double get _kilometers => _hours * 4;

  // حساب عدد الخطوات (1 كم = 1250 خطوة)
  int get _steps => (_kilometers * 1250).round();

  // دالة لتحديد جودة النشاط حسب عدد الساعات (رسائل تحفيزية)
  Map<String, dynamic> _getActivityQuality() {
    if (_hours < 0.5) {
      return {
        'text': 'بداية ممتازة 🌱',
        'color': const Color(0xff66BB6A),
        'message': 'كل خطوة بتبدأ بها، أنت في الطريق الصحيح!',
      };
    } else if (_hours >= 0.5 && _hours < 1) {
      return {
        'text': 'استمرار جميل 💪',
        'color': const Color(0xff8BC34A),
        'message': 'أحسنت! استمر بهذا النشاط',
      };
    } else if (_hours >= 1 && _hours < 1.5) {
      return {
        'text': 'تقدم رائع 🎯',
        'color': const Color(0xff4CAF50),
        'message': 'رائع! أنت تبني عادة صحية جميلة',
      };
    } else if (_hours >= 1.5 && _hours <= 2.5) {
      return {
        'text': 'إنجاز مميز 🌟',
        'color': const Color(0xff2E7D32),
        'message': 'ممتاز! هذا نشاط يومي ممتاز لصحتك',
      };
    } else if (_hours > 2.5 && _hours <= 4) {
      return {
        'text': 'قمة النشاط 🔥',
        'color': const Color(0xffFF8C42),
        'message': 'أكثر من رائع! أنت قدوة في النشاط',
      };
    } else {
      return {
        'text': 'أسطوري 🏆',
        'color': const Color(0xffD32F2F),
        'message': 'لا شيء يوقفك! أنت أسطورة في النشاط الرياضي',
      };
    }
  }

  // تحويل الساعات لصيغة مقروءة (ساعات ودقائق)
  String _formatHours(double hours) {
    int hrs = hours.floor();
    int mins = ((hours - hrs) * 60).round();

    if (hrs == 0) {
      return '$mins دقيقة';
    } else if (mins == 0) {
      return '$hrs ساعة';
    } else {
      return '$hrs ساعة و $mins دقيقة';
    }
  }

  @override
  Widget build(BuildContext context) {
    final quality = _getActivityQuality();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل المشي', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xff6BAF1A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffF1F8E9), Colors.white],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // العنوان
                      const Text(
                        'كم ساعة مشيت اليوم؟',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2D5A0E),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // أيقونة المشي
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xffD6EFA0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_walk,
                          size: 50,
                          color: Color(0xff6BAF1A),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // عرض الساعات
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _hours.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff2D5A0E),
                            ),
                          ),
                          const Text(
                            ' ساعة',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff6BAF1A),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // عرض بالدقائق
                      Text(
                        _formatHours(_hours),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xff8BC34A),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // مؤشر جودة النشاط (بخط كبير ورسائل تحفيزية)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: quality['color'].withOpacity(0.15),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          children: [
                            Text(
                              quality['text'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: quality['color'],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              quality['message'],
                              style: TextStyle(
                                fontSize: 15,
                                color: quality['color'],
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // عرض التفاصيل (كيلومترات وخطوات)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffEEF7CC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '≈ ${_kilometers.toStringAsFixed(1)} كم',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xff6BAF1A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '≈ $_steps خطوة',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xff6BAF1A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Slider لاختيار الساعات (من 0 إلى 5 ساعات)
                      Slider(
                        value: _hours,
                        min: 0,
                        max: 5,
                        divisions: 100,
                        activeColor: const Color(0xff6BAF1A),
                        inactiveColor: const Color(0xffD6EFA0),
                        thumbColor: const Color(0xff6BAF1A),
                        onChanged: (value) {
                          setState(() {
                            _hours = value;
                          });
                        },
                      ),

                      const SizedBox(height: 8),

                      // أزرار سريعة بالساعات
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildQuickButton(0.5, 'نصف ساعة'),
                          _buildQuickButton(1, 'ساعة'),
                          _buildQuickButton(1.5, 'ساعة ونص'),
                          _buildQuickButton(2, 'ساعتين'),
                          _buildQuickButton(2.5, 'ساعتين ونص'),
                          _buildQuickButton(3, '3 ساعات'),
                          _buildQuickButton(4, '4 ساعات'),
                          _buildQuickButton(5, '5 ساعات'),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // زر الحفظ
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveSteps,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6BAF1A),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'حفظ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // أزرار سريعة لاختيار عدد الساعات
  Widget _buildQuickButton(double hours, String label) {
    bool isSelected = (_hours >= hours - 0.1 && _hours <= hours + 0.1);
    return GestureDetector(
      onTap: () {
        setState(() {
          _hours = hours;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff6BAF1A) : const Color(0xffEEF7CC),
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xffD6EFA0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xff2D5A0E),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // حفظ البيانات في Firebase
  Future<void> _saveSteps() async {
    setState(() => _isSaving = true);

    try {
      final userDataService = UserDataService();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        UserData? currentData = await userDataService.getUserData();

        UserData updatedData = UserData(
          userId: user.uid,
          gender: currentData?.gender ?? '',
          age: currentData?.age ?? 0,
          height: currentData?.height ?? 0,
          weight: currentData?.weight ?? 0,
          goal: currentData?.goal ?? '',
          bmr: currentData?.bmr,
          dailyCalories: currentData?.dailyCalories,
          sleepHours: currentData?.sleepHours,
          lastSleepUpdate: currentData?.lastSleepUpdate,
          steps: _steps,
          lastStepsUpdate: DateTime.now(),
        );

        await userDataService.saveUserData(updatedData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ تم حفظ نشاطك اليومي بنجاح'),
              backgroundColor: Color(0xff6BAF1A),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
