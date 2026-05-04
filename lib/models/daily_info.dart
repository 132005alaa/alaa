class DailyInfo {
  final String Date;
  final String Number;
  final String Text;
  final String Emoji;

  DailyInfo({
    required this.Date,
    required this.Number,
    required this.Text,
    required this.Emoji,
  });

  factory DailyInfo.fromJson(Map<String, dynamic> json) {
    return DailyInfo(
      Date: json['Date']?.toString() ?? '',
      Number: json['Number']?.toString() ?? 'معلومة جديدة',
      Text: json['Text']?.toString() ?? '',
      Emoji: json['Emoji']?.toString() ?? '💡',
    );
  }
}
