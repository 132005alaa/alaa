import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthy_food/features/authentication/screens/LoginScreen.dart';
import 'package:healthy_food/features/profile/EditProfilePage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:healthy_food/core/utils/shared_preferences_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:healthy_food/services/user_data_service.dart';
import '../../../models/user_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _profileImagePath;
  double _userRating = 0;
  // ignore: unused_field
  UserData? _userData;
  bool _isLoading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadUserName(),
      _loadProfileImage(),
      _loadUserRating(),
      _loadUserData(),
    ]);
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    final freshUser = FirebaseAuth.instance.currentUser;
    if (mounted) {
      setState(() {
        _userName =
            freshUser?.displayName ??
            freshUser?.email?.split('@').first ??
            'مستخدم';
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userDataService = UserDataService();
      final data = await userDataService.getUserData();
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _imageKeyForUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return 'profile_image_$uid';
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_imageKeyForUser());
    if (mounted) {
      setState(() => _profileImagePath = path);
    }
  }

  Future<void> _saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_imageKeyForUser(), path);
  }

  Future<void> _deleteProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_imageKeyForUser());
    if (mounted) setState(() => _profileImagePath = null);
  }

  Future<void> _loadUserRating() async {
    final rating = await SharedPreferencesHelper.getAppRating();
    if (mounted) setState(() => _userRating = rating ?? 0);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      await _saveProfileImage(pickedFile.path);
      if (mounted) setState(() => _profileImagePath = pickedFile.path);
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('صورة البروفايل'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('الكاميرا'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('المعرض'),
          ),
          if (_profileImagePath != null)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _deleteProfileImage();
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'حذف الصورة',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.048),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff6BAF1A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffF1F8E9), Colors.white],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          children: [
            SizedBox(height: screenHeight * 0.02),

            Center(
              child: GestureDetector(
                onTap: _showImagePickerDialog,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.14,
                      backgroundColor: const Color(0xff6BAF1A),
                      backgroundImage: _profileImagePath != null
                          ? FileImage(File(_profileImagePath!))
                          : null,
                      child: _profileImagePath == null
                          ? Icon(
                              Icons.person,
                              size: screenWidth * 0.14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.015),
                        decoration: const BoxDecoration(
                          color: Color(0xff6BAF1A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: screenWidth * 0.055,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.015),

            Center(
              child: Text(
                _isLoading ? 'جاري التحميل...' : _userName,
                style: TextStyle(
                  fontSize: screenWidth * 0.048,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            _buildSectionHeader(
              'الحساب الشخصي',
              Icons.person_outline,
              screenWidth,
            ),
            SizedBox(height: screenHeight * 0.008),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.edit_outlined,
                title: 'بياناتي الشخصية',
                subtitle: 'تعديل الاسم، الوزن، الطول، الهدف',
                screenWidth: screenWidth,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                  if (result == true && mounted) {
                    await _loadUserName();
                    await _loadUserData();
                  }
                },
              ),
            ]),

            SizedBox(height: screenHeight * 0.025),

            _buildSectionHeader('معلومات', Icons.info_outline, screenWidth),
            SizedBox(height: screenHeight * 0.008),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.info_outline,
                title: 'عن التطبيق',
                subtitle: 'تعرف على التطبيق وإصداره',
                screenWidth: screenWidth,
                onTap: () => _showAboutDialog(),
              ),
              _buildRatingItem(
                icon: Icons.star_outline,
                title: 'تقييم التطبيق',
                subtitle: 'قيم التطبيق من 5 نجوم',
                rating: _userRating,
                screenWidth: screenWidth,
                onRatingChanged: (rating) async {
                  setState(() => _userRating = rating);
                  await SharedPreferencesHelper.saveAppRating(rating);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('شكراً لتقييمك $rating نجوم!'),
                        backgroundColor: const Color(0xff6BAF1A),
                      ),
                    );
                  }
                },
              ),
              _buildSettingsItem(
                icon: Icons.share_outlined,
                title: 'مشاركة التطبيق',
                subtitle: 'شارك التطبيق مع أصدقائك',
                screenWidth: screenWidth,
                onTap: _shareApp,
              ),
            ]),

            SizedBox(height: screenHeight * 0.025),

            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.logout,
                title: 'تسجيل الخروج',
                subtitle: 'الخروج من حسابك الحالي',
                screenWidth: screenWidth,
                onTap: () => _showLogoutDialog(),
                isDestructive: true,
              ),
            ]),

            SizedBox(height: screenHeight * 0.015),

            Center(
              child: Text(
                'الإصدار 1.0.0',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, double screenWidth) {
    return Row(
      children: [
        Icon(icon, size: screenWidth * 0.055, color: const Color(0xff6BAF1A)),
        SizedBox(width: screenWidth * 0.02),
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: const Color(0xff2D5A0E),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required double screenWidth,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.035,
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : const Color(0xffEEF7CC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: screenWidth * 0.055,
                color: isDestructive ? Colors.red : const Color(0xff6BAF1A),
              ),
            ),
            SizedBox(width: screenWidth * 0.035),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.005),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: screenWidth * 0.04,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required double rating,
    required double screenWidth,
    required Function(double) onRatingChanged,
  }) {
    return GestureDetector(
      onTap: () => _showRatingDialog(onRatingChanged),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.035,
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: const Color(0xffEEF7CC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: screenWidth * 0.055,
                color: const Color(0xff6BAF1A),
              ),
            ),
            SizedBox(width: screenWidth * 0.035),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.005),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: screenWidth * 0.045,
                );
              }),
            ),
            SizedBox(width: screenWidth * 0.02),
            Icon(
              Icons.arrow_forward_ios,
              size: screenWidth * 0.04,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(Function(double) onRatingChanged) {
    double tempRating = 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('تقييم التطبيق'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rate, size: 50, color: Colors.amber),
                const SizedBox(height: 16),
                const Text(
                  'ما مدى رضاك عن التطبيق؟',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () =>
                          setDialogState(() => tempRating = index + 1.0),
                      icon: Icon(
                        index < tempRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  tempRating == 0
                      ? '👆 اضغط على النجوم لتقييم'
                      : '⭐ قيمتك: ${tempRating.toStringAsFixed(0)} / 5',
                  style: TextStyle(
                    fontSize: 14,
                    color: tempRating == 0
                        ? Colors.grey
                        : const Color(0xff6BAF1A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (tempRating > 0) {
                    onRatingChanged(tempRating);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ من فضلك اختر تقييمك أولاً'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6BAF1A),
                ),
                child: const Text('إرسال التقييم'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عن التطبيق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Center(
              child: Icon(Icons.food_bank, size: 60, color: Color(0xff6BAF1A)),
            ),
            SizedBox(height: 16),
            Text(
              'Healthy Food هو تطبيق يساعدك على تبني نمط حياة صحي من خلال:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• تتبع وجباتك اليومية وسعراتك الحرارية'),
                  SizedBox(height: 4),
                  Text('• خطط غذائية مخصصة حسب أهدافك'),
                  SizedBox(height: 4),
                  Text('• تذكير بشرب الماء والوجبات'),
                  SizedBox(height: 4),
                  Text('• متابعة تطور وزنك وقياساتك'),
                ],
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'الإصدار 1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareApp() async {
    const String appLink =
        'https://play.google.com/store/apps/details?id=com.healthyfood.app';
    const String message =
        'مرحباً، أدعوك لتجربة تطبيق Healthy Food للأكل الصحي!\n$appLink';
    await Share.share(message);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
