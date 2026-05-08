import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  void _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('saved_email');
    if (savedEmail != null) {
      _emailController.text = savedEmail;
      setState(() => _rememberMe = true);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: screenHeight * 0.09),

              // ── العنوان ──
              Center(
                child: Text(
                  'تسجيل دخول',
                  style: TextStyle(
                    fontSize: screenWidth * 0.075,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.012),

              Center(
                child: Text(
                  'برجاء تسجيل الدخول الي حسابك الحالي',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

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

              // ── البريد الإلكتروني ──
              Text(
                'البريد الالكتروني',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: screenHeight * 0.01),

              TextField(
                controller: _emailController,
                textAlign: TextAlign.right,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'email@gmail.com',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: screenWidth * 0.038,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.022),

              // ── كلمة المرور ──
              Text(
                'كلمه المرور',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: screenHeight * 0.01),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: '**********',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: screenWidth * 0.038,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade700,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.015),

              // ── تذكرني ونسيت كلمة المرور ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/forgot'),
                    child: Text(
                      'نسيت كلمه المرور',
                      style: TextStyle(
                        color: const Color(0xff9ACD32),
                        fontSize: screenWidth * 0.038,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Row(
                      children: [
                        Text(
                          'تذكرني',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: screenWidth * 0.038,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Container(
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _rememberMe
                                  ? const Color(0xff9ACD32)
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: _rememberMe
                                ? const Color(0xff9ACD32)
                                : Colors.transparent,
                          ),
                          child: _rememberMe
                              ? Icon(
                                  Icons.check,
                                  size: screenWidth * 0.035,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.035),

              // ── زر تسجيل الدخول ──
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signIn,
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
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: screenWidth * 0.048,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),

              SizedBox(height: screenHeight * 0.025),

              // ── الانتقال للتسجيل ──
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/register'),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'ليس لدي حساب؟',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.043,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: ' سجل الان',
                          style: TextStyle(
                            color: const Color(0xff9ACD32),
                            fontSize: screenWidth * 0.043,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              Center(
                child: Text(
                  'او',
                  style: TextStyle(
                    fontSize: screenWidth * 0.058,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // ── أيقونات التواصل الاجتماعي ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(Icons.apple, () {}, screenWidth),
                  SizedBox(width: screenWidth * 0.1),
                  _buildSocialIconNetwork(
                    'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                    () {},
                    screenWidth,
                  ),
                  SizedBox(width: screenWidth * 0.1),
                  _buildSocialIconNetwork(
                    'https://cdn-icons-png.flaticon.com/512/733/733547.png',
                    () {},
                    screenWidth,
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'من فضلك أدخل البريد الإلكتروني وكلمة المرور';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString('saved_email', _emailController.text.trim());
        } else {
          await prefs.remove('saved_email');
        }

        if (!mounted) return;

        if (userCredential.user!.emailVerified) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/success');
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'user-not-found':
          message = 'لا يوجد مستخدم بهذا البريد الإلكتروني';
          break;
        case 'wrong-password':
          message = 'كلمة المرور غير صحيحة';
          break;
        case 'invalid-email':
          message = 'البريد الإلكتروني غير صالح';
          break;
        case 'user-disabled':
          message = 'هذا الحساب معطل';
          break;
        case 'too-many-requests':
          message = 'تم حظر الوصول مؤقتاً. حاول مرة أخرى لاحقاً';
          break;
        default:
          message = 'حدث خطأ: ${e.message}';
      }
      setState(() => _errorMessage = message);
    } catch (e) {
      print('Error during login: $e');
      setState(() => _errorMessage = 'حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSocialIcon(
    IconData icon,
    VoidCallback onTap,
    double screenWidth,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.14,
        height: screenWidth * 0.14,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, size: screenWidth * 0.11, color: Colors.black),
      ),
    );
  }

  Widget _buildSocialIconNetwork(
    String imageUrl,
    VoidCallback onTap,
    double screenWidth,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.14,
        height: screenWidth * 0.14,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Image.network(
            imageUrl,
            width: screenWidth * 0.08,
            height: screenWidth * 0.08,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
