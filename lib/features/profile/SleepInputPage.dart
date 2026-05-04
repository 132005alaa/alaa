import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_data_service.dart';
import '../../models/user_data_model.dart';

class SleepInputPage extends StatefulWidget {
  const SleepInputPage({super.key});

  @override
  State<SleepInputPage> createState() => _SleepInputPageState();
}

class _SleepInputPageState extends State<SleepInputPage> {
  double _sleepHours = 7.0;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل ساعات النوم'),
        centerTitle: true,
        backgroundColor: const Color(0xff6BAF1A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xffD6EFA0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  const Text(
                    'كم ساعة نمت اليوم؟',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2D5A0E),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🎚️ أيقونة النوم
                  const Icon(Icons.bedtime, size: 60, color: Color(0xff2D5A0E)),
                  const SizedBox(height: 20),

                  // 🕐 عرض الساعات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _sleepHours.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2D5A0E),
                        ),
                      ),
                      const Text(
                        ' ساعة',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff2D5A0E),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🎚️ Slider لاختيار الساعات
                  Slider(
                    value: _sleepHours,
                    min: 0,
                    max: 12,
                    divisions: 24,
                    activeColor: const Color(0xff6BAF1A),
                    inactiveColor: Colors.grey.shade300,
                    onChanged: (value) {
                      setState(() {
                        _sleepHours = value;
                      });
                    },
                  ),

                  // 📊 مؤشر جودة النوم
                  const SizedBox(height: 10),
                  _buildSleepQualityIndicator(_sleepHours),

                  const SizedBox(height: 30),

                  // 💾 زر الحفظ
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveSleepHours,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6BAF1A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
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
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 مؤشر جودة النوم
  Widget _buildSleepQualityIndicator(double hours) {
    String qualityText;
    Color qualityColor;

    if (hours >= 7 && hours <= 9) {
      qualityText = 'ممتاز 🌟';
      qualityColor = Colors.green;
    } else if (hours >= 6 && hours < 7) {
      qualityText = 'جيد ✅';
      qualityColor = Colors.orange;
    } else if (hours >= 9 && hours <= 10) {
      qualityText = 'كثير نوعاً ما 😴';
      qualityColor = Colors.orange;
    } else if (hours < 6) {
      qualityText = 'قليل ⚠️';
      qualityColor = Colors.red;
    } else {
      qualityText = 'كثير جداً 😵';
      qualityColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: qualityColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        qualityText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: qualityColor,
        ),
      ),
    );
  }

  // 💾 حفظ ساعات النوم في Firebase
  Future<void> _saveSleepHours() async {
    setState(() => _isSaving = true);

    try {
      final userDataService = UserDataService();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // جلب البيانات الحالية للمستخدم
        UserData? currentData = await userDataService.getUserData();

        // إنشاء كائن محدث مع ساعات النوم الجديدة
        UserData updatedData = UserData(
          userId: user.uid,
          gender: currentData?.gender ?? '',
          age: currentData?.age ?? 0,
          height: currentData?.height ?? 0,
          weight: currentData?.weight ?? 0,
          goal: currentData?.goal ?? '',
          bmr: currentData?.bmr,
          dailyCalories: currentData?.dailyCalories,
          sleepHours: _sleepHours, // 🆕 ساعات النوم الجديدة
          lastSleepUpdate: DateTime.now(),
        );

        // حفظ في Firebase
        await userDataService.saveUserData(updatedData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ تم حفظ ساعات النوم بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // رجوع مع تحديث
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
