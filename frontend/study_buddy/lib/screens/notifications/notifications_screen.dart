import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notification> _notifications = [
    _Notification(
      icon: Icons.person_add_outlined,
      title: 'Priya Sharma wants to connect',
      subtitle: 'She studies Machine Learning at PCCOE',
      time: '2 min ago',
      isRead: false,
      type: 'connect',
    ),
    _Notification(
      icon: Icons.group_outlined,
      title: 'New session: DSA Interview Prep',
      subtitle: 'Starting in 2 hours at PCCOE Library',
      time: '15 min ago',
      isRead: false,
      type: 'session',
    ),
    _Notification(
      icon: Icons.chat_outlined,
      title: 'Aman sent a message',
      subtitle: '"Ready for the ML session today?"',
      time: '1 hr ago',
      isRead: false,
      type: 'message',
    ),
    _Notification(
      icon: Icons.location_on_outlined,
      title: '3 students nearby',
      subtitle: 'Sneha, Rohan and 1 other are within 2km',
      time: '2 hrs ago',
      isRead: true,
      type: 'nearby',
    ),
    _Notification(
      icon: Icons.check_circle_outline,
      title: 'Rohan accepted your connect',
      subtitle: 'You can now chat with Rohan Kulkarni',
      time: '3 hrs ago',
      isRead: true,
      type: 'connect',
    ),
    _Notification(
      icon: Icons.star_outline,
      title: 'Session completed!',
      subtitle: 'Flutter App Development session ended',
      time: 'Yesterday',
      isRead: true,
      type: 'session',
    ),
    _Notification(
      icon: Icons.local_fire_department_outlined,
      title: 'Study streak reminder',
      subtitle: 'Keep your 7-day streak alive! Study today.',
      time: 'Yesterday',
      isRead: true,
      type: 'reminder',
    ),
  ];

  Color _iconColor(String type) {
    switch (type) {
      case 'connect':
        return Colors.blue;
      case 'session':
        return Colors.green;
      case 'message':
        return Colors.purple;
      case 'nearby':
        return Colors.orange;
      case 'reminder':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Notifications ${unread > 0 ? "($unread)" : ""}'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n.isRead = true;
                }
              });
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.black, fontSize: 13),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications yet',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('We\'ll notify you when something happens',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final n = _notifications[index];
                return GestureDetector(
                  onTap: () => setState(() => n.isRead = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: n.isRead ? Colors.white : const Color(0xFFF8F8F8),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _iconColor(n.type).withAlpha(26),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child:
                              Icon(n.icon, size: 22, color: _iconColor(n.type)),
                        ),
                        const SizedBox(width: 12),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      n.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: n.isRead
                                            ? FontWeight.normal
                                            : FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  if (!n.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.subtitle,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.time,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _Notification {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  bool isRead;
  final String type;

  _Notification({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isRead,
    required this.type,
  });
}
