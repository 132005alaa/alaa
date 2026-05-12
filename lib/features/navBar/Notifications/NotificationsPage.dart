import 'package:flutter/material.dart';
import '../../../models/notification_model.dart';
import '../../../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int selectedTab = 0;
  Set<String> favorites = {};
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notificationService.getNotifications().listen((notifications) {
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    });
  }

  List<NotificationModel> get displayedNotifications {
    if (selectedTab == 1) {
      return _notifications.where((n) => favorites.contains(n.id)).toList();
    }
    return _notifications;
  }

  Map<String, List<NotificationModel>> _groupByTime(
    List<NotificationModel> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final Map<String, List<NotificationModel>> grouped = {
      'اليوم': [],
      'أمس': [],
      'الأسبوع الماضي': [],
      'أقدم من ذلك': [],
    };

    for (var n in notifications) {
      final nDate = DateTime(
        n.timestamp.year,
        n.timestamp.month,
        n.timestamp.day,
      );

      if (nDate == today) {
        grouped['اليوم']!.add(n);
      } else if (nDate == yesterday) {
        grouped['أمس']!.add(n);
      } else if (nDate.isAfter(weekAgo)) {
        grouped['الأسبوع الماضي']!.add(n);
      } else {
        grouped['أقدم من ذلك']!.add(n);
      }
    }

    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  Future<void> _deleteNotification(String id) async {
    await _notificationService.deleteNotification(id);
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
      favorites.remove(id);
    });
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح الإشعارات'),
        content: const Text('هل تريد مسح كل الإشعارات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              for (var n in List.from(_notifications)) {
                await _notificationService.deleteNotification(n.id);
              }
              setState(() {
                _notifications.clear();
                favorites.clear();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final grouped = _groupByTime(displayedNotifications);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // ── Header ──
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.016,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زرار مسح الكل
                        _notifications.isEmpty
                            ? SizedBox(width: screenWidth * 0.1)
                            : GestureDetector(
                                onTap: _showClearAllDialog,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03,
                                    vertical: screenHeight * 0.008,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    'مسح الكل',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.032,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                        Text(
                          'الاشعارات',
                          style: TextStyle(
                            fontSize: screenWidth * 0.065,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.06),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_left,
                              size: screenWidth * 0.06,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                    ),
                    child: Row(
                      children: [
                        _buildTab(
                          label: 'المفضله',
                          icon: Icons.favorite,
                          index: 1,
                          screenWidth: screenWidth,
                        ),
                        _buildTab(
                          label: 'الرسائل',
                          icon: Icons.chat_bubble,
                          index: 0,
                          screenWidth: screenWidth,
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xffE0E0E0)),

                  Expanded(
                    child: grouped.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_off_outlined,
                                  size: screenWidth * 0.18,
                                  color: Colors.grey.shade300,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  selectedTab == 1
                                      ? 'لا توجد إشعارات مفضلة'
                                      : 'لا توجد إشعارات',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: screenWidth * 0.042,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.012,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: grouped.entries.map((entry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.01,
                                        horizontal: screenWidth * 0.01,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            entry.key,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.038,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.02),
                                          Container(
                                            width: screenWidth * 0.12,
                                            height: 1.5,
                                            color: Colors.grey.shade300,
                                          ),
                                        ],
                                      ),
                                    ),

                                    ...entry.value.map((notification) {
                                      return _buildNotificationCard(
                                        notification,
                                        favorites.contains(notification.id),
                                        screenWidth,
                                        screenHeight,
                                      );
                                    }),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required int index,
    required double screenWidth,
  }) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: screenWidth * 0.055,
                  color: isSelected ? const Color(0xff6BAF1A) : Colors.grey,
                ),
                SizedBox(width: screenWidth * 0.015),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black87 : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    bool isFav,
    double screenWidth,
    double screenHeight,
  ) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.012),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: screenWidth * 0.05),
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: screenWidth * 0.07,
        ),
      ),
      onDismissed: (_) => _deleteNotification(notification.id),
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.012),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.035,
          vertical: screenHeight * 0.015,
        ),
        decoration: BoxDecoration(
          color: notification.isRead
              ? const Color(0xffF5F5F5)
              : const Color(0xffE8F5C0),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _deleteNotification(notification.id),
              child: Icon(
                Icons.close,
                color: Colors.grey.shade400,
                size: screenWidth * 0.05,
              ),
            ),

            SizedBox(width: screenWidth * 0.02),

            GestureDetector(
              onTap: () {
                setState(() {
                  if (isFav) {
                    favorites.remove(notification.id);
                  } else {
                    favorites.add(notification.id);
                  }
                });
              },
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : Colors.grey.shade400,
                size: screenWidth * 0.055,
              ),
            ),

            SizedBox(width: screenWidth * 0.025),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.042,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff3A2A0A),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: screenHeight * 0.004),
                  Text(
                    notification.subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: const Color(0xff7A6A4A),
                      height: 1.4,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: screenHeight * 0.004),
                  Text(
                    _formatTime(notification.timestamp),
                    style: TextStyle(
                      fontSize: screenWidth * 0.028,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: screenWidth * 0.025),

            Text(
              notification.emoji,
              style: TextStyle(fontSize: screenWidth * 0.07),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    return 'منذ ${diff.inDays} يوم';
  }
}
