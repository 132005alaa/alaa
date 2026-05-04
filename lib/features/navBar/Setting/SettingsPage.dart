import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthy_food/features/authentication/screens/LoginScreen.dart';
import 'package:healthy_food/features/profile/EditProfilePage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

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
            _buildSectionHeader('الحساب الشخصي', Icons.person_outline),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.edit_outlined,
                title: 'بياناتي الشخصية',
                subtitle: 'تعديل الاسم، الوزن، الطول، الهدف',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                icon: Icons.lock_outline,
                title: 'تغيير كلمة المرور',
                subtitle: 'تحديث كلمة المرور لحماية حسابك',
                onTap: () => _showChangePasswordDialog(),
              ),
              _buildSettingsItem(
                icon: Icons.logout,
                title: 'تسجيل الخروج',
                subtitle: 'الخروج من حسابك الحالي',
                onTap: () => _showLogoutDialog(),
                isDestructive: true,
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader('تفضيلات التطبيق', Icons.settings_outlined),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildSwitchItem(
                icon: Icons.notifications_outlined,
                title: 'إشعارات اليوم',
                subtitle: 'تذكير بالوجبات والنشاط اليومي',
                value: _notificationsEnabled,
                onChanged: (value) =>
                    setState(() => _notificationsEnabled = value),
              ),
              _buildSwitchItem(
                icon: Icons.dark_mode_outlined,
                title: 'الوضع الداكن',
                subtitle: 'تغيير مظهر التطبيق',
                value: _darkModeEnabled,
                onChanged: (value) => setState(() => _darkModeEnabled = value),
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
              _buildSettingsItem(
                icon: Icons.star_outline,
                title: 'تقييم التطبيق',
                subtitle: 'قيم التطبيق في المتجر',
                onTap: () => _rateApp(),
              ),
              _buildSettingsItem(
                icon: Icons.share_outlined,
                title: 'مشاركة التطبيق',
                subtitle: 'شارك التطبيق مع أصدقائك',
                onTap: () => _shareApp(),
              ),
            ]),
            const SizedBox(height: 16),

            Container(
              alignment: Alignment.center,
              child: Text(
                'الإصدار 1.0.0',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
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

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xff6BAF1A),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: const Text(
          'سيتم إرسال رابط لتغيير كلمة المرور إلى بريدك الإلكتروني',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && user.email != null) {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: user.email!,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال رابط التغيير إلى بريدك'),
                    backgroundColor: Color(0xff6BAF1A),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6BAF1A),
            ),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عن التطبيق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.food_bank, size: 50, color: Color(0xff6BAF1A)),
            const SizedBox(height: 12),
            const Text(
              'Healthy Food',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('تطبيق للأكل الصحي', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              'الإصدار 1.0.0',
              style: TextStyle(color: Colors.grey.shade600),
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

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('شكراً لتقييمك!'),
        backgroundColor: Color(0xff6BAF1A),
      ),
    );
  }

  void _shareApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الرابط'),
        backgroundColor: Color(0xff6BAF1A),
      ),
    );
  }
}
