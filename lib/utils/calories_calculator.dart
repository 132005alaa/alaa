class CaloriesCalculator {
  static double calculateBMR({
    required String gender,
    required int age,
    required double height, // cm
    required double weight, // kg
  }) {
    if (gender == 'ذكر') {
      return 66 + (13.7 * weight) + (5 * height) - (6.8 * age);
    } else {
      return 655 + (9.6 * weight) + (1.8 * height) - (4.7 * age);
    }
  }

  static double calculateDailyCalories({
    required double bmr,
    required String goal,
  }) {
    if (goal == 'خسارة وزن') {
      return bmr - 500;
    } else if (goal == 'زيادة عضلات' || goal == 'زيادة وزن') {
      return bmr + 500;
    } else {
      return bmr;
    }
  }

  static double calculateBMI({required double weight, required double height}) {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  static String interpretBMI(double bmi) {
    if (bmi < 18.5) return 'نحافة';
    if (bmi < 25) return 'وزن طبيعي';
    if (bmi < 30) return 'وزن زائد';
    return 'سمنة';
  }
}
