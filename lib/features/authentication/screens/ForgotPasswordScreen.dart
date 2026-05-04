import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  // String? _successMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 100),

              // زر الرجوع
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // العنوان
              const Center(
                child: Text(
                  'نسيان كلمه المرور',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 15),

              // الوصف
              Center(
                child: Text(
                  'برجاء إدخال البريد الإلكتروني لإرسال رابط إعادة تعيين كلمة المرور',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
                ),
              ),

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

              // رسالة النجاح
              // if (_successMessage != null)
              //   Container(
              //     width: double.infinity,
              //     padding: const EdgeInsets.all(12),
              //     margin: const EdgeInsets.only(bottom: 20),
              //     decoration: BoxDecoration(
              //       color: Colors.green.shade50,
              //       borderRadius: BorderRadius.circular(10),
              //       border: Border.all(color: Colors.green.shade200),
              //     ),
              //     child: Text(
              //       _successMessage!,
              //       style: TextStyle(color: Colors.green.shade800),
              //       textAlign: TextAlign.center,
              //     ),
              //   ),
              Text(
                'البريد الالكتروني',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _emailController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'email@gmail.com',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),

              const SizedBox(height: 150),

              // زر ارسال الرابط
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff9ACD32),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                        child: const Text(
                          'ارسال الرابط',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // دالة إرسال رابط إعادة تعيين كلمة المرور
  Future<void> _resetPassword() async {
    // التحقق من الحقل
    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains('@')) {
      setState(() {
        _errorMessage = 'من فضلك أدخل بريد إلكتروني صحيح';
        // _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      // _successMessage = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // 👇 هنا
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '📩 تم إرسال الرابط، تحقق من بريدك الإلكتروني',
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color(0xff4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          duration: const Duration(seconds: 3),
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'invalid-email':
          message = 'البريد الإلكتروني غير صالح';
          break;
        case 'user-not-found':
          message = 'لا يوجد مستخدم بهذا البريد الإلكتروني';
          break;
        case 'too-many-requests':
          message = 'تم إرسال العديد من الطلبات. حاول مرة أخرى لاحقاً';
          break;
        default:
          message = 'حدث خطأ: ${e.message}';
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ غير متوقع';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
