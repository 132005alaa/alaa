class CaloriesCalculator {
  // حساب معدل الحرق الأساسي (BMR)
  static double calculateBMR({
    required String gender,
    required int age,
    required double height, // cm
    required double weight, // kg
  }) {
    if (gender == 'ذكر') {
      // معادلة الرجال
      return 66 + (13.7 * weight) + (5 * height) - (6.8 * age);
    } else {
      // معادلة النساء
      return 655 + (9.6 * weight) + (1.8 * height) - (4.7 * age);
    }
  }

  // حساب السعرات حسب الهدف
  static double calculateDailyCalories({
    required double bmr,
    required String goal,
  }) {
    if (goal == 'خسارة وزن') {
      return bmr - 500; // تخسيس
    } else if (goal == 'زيادة عضلات' || goal == 'زيادة وزن') {
      return bmr + 500; // زيادة
    } else {
      return bmr; // تثبيت
    }
  }

  // حساب الـ BMI (اختياري)
  static double calculateBMI({required double weight, required double height}) {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // تفسير الـ BMI
  static String interpretBMI(double bmi) {
    if (bmi < 18.5) return 'نحافة';
    if (bmi < 25) return 'وزن طبيعي';
    if (bmi < 30) return 'وزن زائد';
    return 'سمنة';
  }
}
