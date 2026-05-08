import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: screenHeight * 0.07),

              // ── زرار الرجوع ──
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: screenWidth * 0.045,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.035),

              // ── العنوان ──
              Center(
                child: Text(
                  'انشاء حساب',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.008),

              Center(
                child: Text(
                  'من فضلك سجل الدخول للبدء',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // ── رسالة الخطأ ──
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  margin: EdgeInsets.only(bottom: screenHeight * 0.02),
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

              // ── الاسم ──
              _buildLabel('الاسم', screenWidth),
              SizedBox(height: screenHeight * 0.008),
              _buildTextField(
                controller: _nameController,
                hint: 'ادخل اسمك',
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),

              SizedBox(height: screenHeight * 0.02),

              // ── البريد الإلكتروني ──
              _buildLabel('البريد الالكتروني', screenWidth),
              SizedBox(height: screenHeight * 0.008),
              _buildTextField(
                controller: _emailController,
                hint: 'email@gmail.com',
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: screenHeight * 0.02),

              // ── كلمة المرور ──
              _buildLabel('كلمه المرور', screenWidth),
              SizedBox(height: screenHeight * 0.008),
              _buildTextField(
                controller: _passwordController,
                hint: '************',
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade700,
                    size: screenWidth * 0.055,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // ── تأكيد كلمة المرور ──
              _buildLabel('تأكيد كلمه المرور', screenWidth),
              SizedBox(height: screenHeight * 0.008),
              _buildTextField(
                controller: _confirmPasswordController,
                hint: '************',
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade700,
                    size: screenWidth * 0.055,
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.07),

              // ── زرار التسجيل ──
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff9ACD32),
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.08,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'سجل الان',
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
    );
  }

  Widget _buildLabel(String text, double screenWidth) {
    return Text(
      text,
      style: TextStyle(
        fontSize: screenWidth * 0.045,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required double screenWidth,
    required double screenHeight,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: screenWidth * 0.038,
        ),
        filled: true,
        fillColor: Colors.grey.shade300,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty) {
      setState(() => _errorMessage = 'من فضلك أدخل الاسم');
      return;
    }
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = 'من فضلك أدخل البريد الإلكتروني');
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'من فضلك أدخل كلمة المرور');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(
        () => _errorMessage = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'كلمة المرور غير متطابقة');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(
          _nameController.text.trim(),
        );
        await userCredential.user!.reload();
        await userCredential.user!.sendEmailVerification();
        if (mounted) Navigator.pushReplacementNamed(context, '/success');
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'البريد الإلكتروني مستخدم بالفعل';
          break;
        case 'invalid-email':
          message = 'البريد الإلكتروني غير صالح';
          break;
        case 'operation-not-allowed':
          message = 'هذه العملية غير مسموح بها';
          break;
        case 'weak-password':
          message = 'كلمة المرور ضعيفة - استخدم كلمة أقوى';
          break;
        default:
          message = 'حدث خطأ: ${e.message}';
      }
      setState(() => _errorMessage = message);
    } catch (e) {
      setState(() => _errorMessage = 'حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
