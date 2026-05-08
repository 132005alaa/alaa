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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _profileImagePath;
  double _userRating = 0;
  UserData? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUserRating();
    _loadUserData();
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadProfileImage() async {
    final path = await SharedPreferencesHelper.getProfileImagePath();
    if (mounted) {
      setState(() {
        _profileImagePath = path;
      });
    }
  }

  Future<void> _loadUserRating() async {
    final rating = await SharedPreferencesHelper.getAppRating();
    if (mounted) {
      setState(() {
        _userRating = rating ?? 0;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final path = pickedFile.path;
      await SharedPreferencesHelper.saveProfileImagePath(path);
      if (mounted) {
        setState(() {
          _profileImagePath = path;
        });
      }
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر صورة البروفايل'),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(color: Colors.white)),
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
          padding: const EdgeInsets.all(16),
          children: [
            // صورة البروفايل
            Center(
              child: GestureDetector(
                onTap: _showImagePickerDialog,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xff6BAF1A),
                      backgroundImage: _profileImagePath != null
                          ? FileImage(File(_profileImagePath!))
                          : null,
                      child: _profileImagePath == null
                          ? const Icon(
                              Icons.person,
                              size: 55,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xff6BAF1A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _isLoading
                    ? 'جاري التحميل...'
                    : (_userData?.name ?? 'اسم المستخدم'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('الحساب الشخصي', Icons.person_outline),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.edit_outlined,
                title: 'بياناتي الشخصية',
                subtitle: 'تعديل الاسم، الوزن، الطول، الهدف',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                  if (result == true && mounted) {
                    _loadUserData();
                  }
                },
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader('معلومات', Icons.info_outline),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.info_outline,
                title: 'عن التطبيق',
                subtitle: 'تعرف على التطبيق وإصداره',
                onTap: () => _showAboutDialog(),
              ),
              _buildRatingItem(
                icon: Icons.star_outline,
                title: 'تقييم التطبيق',
                subtitle: 'قيم التطبيق من 5 نجوم',
                rating: _userRating,
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
                onTap: _shareApp,
              ),
            ]),
            const SizedBox(height: 24),

            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.logout,
                title: 'تسجيل الخروج',
                subtitle: 'الخروج من حسابك الحالي',
                onTap: () => _showLogoutDialog(),
                isDestructive: true,
              ),
            ]),
            const SizedBox(height: 16),

            Center(
              child: Text(
                'الإصدار 1.0.0',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xff6BAF1A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff2D5A0E),
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
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : const Color(0xffEEF7CC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isDestructive ? Colors.red : const Color(0xff6BAF1A),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
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
    required Function(double) onRatingChanged,
  }) {
    return GestureDetector(
      onTap: () => _showRatingDialog(onRatingChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xffEEF7CC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: const Color(0xff6BAF1A)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                  size: 18,
                );
              }),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
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
                const Center(
                  child: Icon(Icons.star_rate, size: 50, color: Colors.amber),
                ),
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
                      onPressed: () {
                        setDialogState(() {
                          tempRating = index + 1.0;
                        });
                      },
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
          children: [
            const Center(
              child: Icon(Icons.food_bank, size: 60, color: Color(0xff6BAF1A)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Healthy Food هو تطبيق يساعدك على تبني نمط حياة صحي من خلال:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
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
            const SizedBox(height: 16),
            const Center(
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
