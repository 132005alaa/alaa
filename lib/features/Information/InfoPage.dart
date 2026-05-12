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
    if (picked != null) setState(() => selectedDate = picked);
  }

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.012,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: screenWidth * 0.085),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: screenHeight * 0.005),

                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "معلومات عنك",
                        style: TextStyle(
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.006),

                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "اعطنا معومات عنك اكثر",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            color: const Color(0xffB7D957),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 4,
                            color: const Color(0xffE0E0E0),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        margin: EdgeInsets.only(bottom: screenHeight * 0.015),
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

                    _buildLabel("ما هو نوعك؟", screenWidth),
                    SizedBox(height: screenHeight * 0.008),
                    _buildDropdown(screenWidth, screenHeight),

                    SizedBox(height: screenHeight * 0.022),

                    _buildLabel("ما هو طولك؟", screenWidth),
                    SizedBox(height: screenHeight * 0.008),
                    _buildTextField(
                      controller: _heightController,
                      hint: "سم",
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),

                    SizedBox(height: screenHeight * 0.022),

                    _buildLabel("ما هو وزنك؟", screenWidth),
                    SizedBox(height: screenHeight * 0.008),
                    _buildTextField(
                      controller: _weightController,
                      hint: "كجم",
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),

                    SizedBox(height: screenHeight * 0.022),

                    _buildLabel("ما هو عمرك؟", screenWidth),
                    SizedBox(height: screenHeight * 0.008),
                    _buildDateField(context, screenWidth, screenHeight),

                    SizedBox(height: screenHeight * 0.07),

                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.065,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedGender == null) {
                            setState(
                              () => _errorMessage = 'من فضلك اختر النوع',
                            );
                            return;
                          }
                          if (_heightController.text.isEmpty) {
                            setState(
                              () => _errorMessage = 'من فضلك ادخل الطول',
                            );
                            return;
                          }
                          if (_weightController.text.isEmpty) {
                            setState(
                              () => _errorMessage = 'من فضلك ادخل الوزن',
                            );
                            return;
                          }
                          if (selectedDate == null) {
                            setState(
                              () =>
                                  _errorMessage = 'من فضلك اختر تاريخ الميلاد',
                            );
                            return;
                          }

                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });

                          try {
                            int age = _calculateAge(selectedDate!);
                            UserData tempUserData = UserData(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              gender: selectedGender!,
                              age: age,
                              height: double.parse(_heightController.text),
                              weight: double.parse(_weightController.text),
                              goal: '',
                            );
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
                            setState(
                              () => _errorMessage =
                                  'حدث خطأ: تأكد من صحة الأرقام',
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffB7D957),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.08,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                "التالي",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.048,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, double screenWidth) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDropdown(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          hint: Align(
            alignment: Alignment.centerRight,
            child: Text(
              "ذكر/انثى",
              style: TextStyle(
                color: Colors.grey,
                fontSize: screenWidth * 0.04,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black54,
            size: screenWidth * 0.06,
          ),
          items: [
            DropdownMenuItem(
              value: "ذكر",
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "ذكر",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
            ),
            DropdownMenuItem(
              value: "أنثى",
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "أنثى",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
            ),
          ],
          onChanged: (value) => setState(() => selectedGender = value),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required double screenWidth,
    required double screenHeight,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.rtl,
      style: TextStyle(fontSize: screenWidth * 0.04),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.04),
        filled: true,
        fillColor: const Color(0xffF5F5F5),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.018,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    double screenWidth,
    double screenHeight,
  ) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.018,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: screenWidth * 0.055,
              color: Colors.black54,
            ),
            Text(
              selectedDate != null
                  ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                  : "اختر تاريخ ميلادك",
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.black87,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
