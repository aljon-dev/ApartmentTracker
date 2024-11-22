// lib/Tenant/notificationPage.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class notificationSubPage extends StatefulWidget {
  final String userid;

  const notificationSubPage({Key? key, required this.userid}) : super(key: key);

  @override
  _notificationPageState createState() => _notificationPageState();
}

class _notificationPageState extends State<notificationSubPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
       stream: _firestore
            .collection('notifications')
            .where('userId',isEqualTo: widget.userid)
            .where('type', isNotEqualTo: 'message')  
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;

              // Get icon and color based on notification type
              IconData icon;
              Color color;
              switch (notification['type']) {
                case 'maintenance':
                  icon = Icons.build;
                  color = Colors.orange;
                  break;
                case 'key_request':
                  icon = Icons.key;
                  color = Colors.green;
                  break;
                case 'payment':
                  icon = Icons.payment;
                  color = Colors.blue;
                  break;
         
                case 'announcement':
                  icon = Icons.announcement;
                  color = Colors.red;
                  break;
                default:
                  icon = Icons.notifications;
                  color = Colors.grey;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(
                    notification['title'],
                    style: TextStyle(
                      fontWeight: notification['isRead']
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification['message']),
                      Text(
                        _formatTimestamp(notification['timestamp']),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Mark as read when tapped
                    if (!notification['isRead']) {
                      notifications[index].reference.update({'isRead': true});
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final date = timestamp.toDate();
    if (now.difference(date).inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
