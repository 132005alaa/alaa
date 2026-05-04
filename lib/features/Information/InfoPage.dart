import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthy_food/features/Information/GoalPage.dart';
import '../../models/user_data_model.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  String? selectedGender;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  DateTime? selectedDate;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // دالة جديدة لحساب العمر من تاريخ الميلاد
  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back arrow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 35),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 3),

                    // Title
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "معلومات عنك",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "اعطنا معومات عنك اكثر",
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 4,
                            color: const Color(0xffB7D957),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 4,
                            color: const Color(0xffE0E0E0),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Gender
                    _buildLabel("ما هو نوعك؟"),
                    const SizedBox(height: 8),
                    _buildDropdown(),

                    const SizedBox(height: 22),

                    // Height
                    _buildLabel("ما هو طولك؟"),
                    const SizedBox(height: 8),
                    _buildTextField(controller: _heightController, hint: "سم"),

                    const SizedBox(height: 22),

                    // Weight
                    _buildLabel("ما هو وزنك؟"),
                    const SizedBox(height: 8),
                    _buildTextField(controller: _weightController, hint: "كجم"),

                    const SizedBox(height: 22),

                    // Age / Date
                    _buildLabel("ما هو عمرك؟"),
                    const SizedBox(height: 8),
                    _buildDateField(context),

                    const SizedBox(height: 80),

                    // Next button → يروح لصفحة GoalPage
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          // التحقق من البيانات
                          if (selectedGender == null) {
                            setState(() {
                              _errorMessage = 'من فضلك اختر النوع';
                            });
                            return;
                          }

                          if (_heightController.text.isEmpty) {
                            setState(() {
                              _errorMessage = 'من فضلك ادخل الطول';
                            });
                            return;
                          }

                          if (_weightController.text.isEmpty) {
                            setState(() {
                              _errorMessage = 'من فضلك ادخل الوزن';
                            });
                            return;
                          }

                          if (selectedDate == null) {
                            setState(() {
                              _errorMessage = 'من فضلك اختر تاريخ الميلاد';
                            });
                            return;
                          }

                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });

                          try {
                            // حساب العمر
                            int age = _calculateAge(selectedDate!);

                            // إنشاء كائن UserData مؤقت (هنكمله في GoalPage)
                            UserData tempUserData = UserData(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              gender: selectedGender!,
                              age: age,
                              height: double.parse(_heightController.text),
                              weight: double.parse(_weightController.text),
                              goal: '', // هيتحدد في GoalPage
                            );

                            // نمرر البيانات لصفحة Goal
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GoalPage(),
                                settings: RouteSettings(
                                  arguments: tempUserData,
                                ),
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              _errorMessage = 'حدث خطأ: تأكد من صحة الأرقام';
                            });
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffB7D957),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : const Text(
                                "التالي",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),

                    // بعد الـ Progress bar
                    const SizedBox(height: 30),

                    // رسالة الخطأ
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // وبعدين باقي المحتوى
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          hint: const Align(
            alignment: Alignment.centerRight,
            child: Text(
              "ذكر/انثى",
              style: TextStyle(color: Colors.grey),
              textDirection: TextDirection.rtl,
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: const [
            DropdownMenuItem(
              value: "ذكر",
              child: Align(
                alignment: Alignment.centerRight,
                child: Text("ذكر", textDirection: TextDirection.rtl),
              ),
            ),
            DropdownMenuItem(
              value: "أنثى",
              child: Align(
                alignment: Alignment.centerRight,
                child: Text("أنثى", textDirection: TextDirection.rtl),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xffF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 22,
              color: Colors.black54,
            ),
            Text(
              selectedDate != null
                  ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                  : "اختر تاريخ ميلادك",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
