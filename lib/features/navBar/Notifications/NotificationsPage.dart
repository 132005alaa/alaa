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
  Set<String> favorites = {}; // هتخزن IDs الإشعارات المفضلة

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
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    });
  }

  List<NotificationModel> get displayedNotifications {
    if (selectedTab == 1) {
      return _notifications.where((n) => favorites.contains(n.id)).toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    // Group notifications by section
    final grouped = <String, List<NotificationModel>>{};
    for (var notification in displayedNotifications) {
      grouped.putIfAbsent(notification.section, () => []);
      grouped[notification.section]!.add(notification);
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // ── Header ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back arrow
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.06),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.white, blurRadius: 8),
                              ],
                            ),
                            child: const Icon(Icons.chevron_left, size: 25),
                          ),
                        ),
                        const Text(
                          'الاشعارات',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 40), // balance
                      ],
                    ),
                  ),

                  // ── Tabs ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // المفضله tab
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTab = 1),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      size: 23,
                                      color: selectedTab == 1
                                          ? const Color(0xff6BAF1A)
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'المفضله',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: selectedTab == 1
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: selectedTab == 1
                                            ? Colors.black87
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: selectedTab == 1
                                        ? Colors.black87
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // الرسائل tab
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTab = 0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble,
                                      size: 23,
                                      color: selectedTab == 0
                                          ? const Color(0xff6BAF1A)
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'الرسائل',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: selectedTab == 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: selectedTab == 0
                                            ? Colors.black87
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: selectedTab == 0
                                        ? Colors.black87
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xffE0E0E0)),

                  // ── Scrollable content ──
                  Expanded(
                    child: grouped.isEmpty
                        ? const Center(
                            child: Text(
                              'لا توجد اشعارات مفضلة',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: grouped.entries.map((entry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Section label
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 4,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                    ...entry.value.map((notification) {
                                      return _buildNotificationCard(
                                        notification,
                                        favorites.contains(notification.id),
                                      );
                                    }).toList(),
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

  // ignore: unused_element
  Widget _buildNotificationCard(NotificationModel notification, bool isFav) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: notification.isRead
            ? const Color(0xffF5F5F5)
            : const Color(0xffE8F5C0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Heart icon
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
              color: isFav ? Colors.red : const Color(0xff5A3A1A),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff3A2A0A),
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  notification.subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xff7A6A4A),
                    height: 1.4,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Emoji icon
          Text(notification.emoji, style: const TextStyle(fontSize: 30)),
        ],
      ),
    );
  }
}
