import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  FirebaseApi() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0, // ID
      title,
      body,
      platformChannelSpecifics,
      payload: 'New Payload', // You can pass the post ID or other data as payload
    );
  }

  Future<void> initNotifications() async {
    _firestore.collection('posts').snapshots().listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final postData = change.doc.data() as Map<String, dynamic>;
          final notificationSent = postData['notificationSent'] ?? false;
          if (!notificationSent) {
            final postCategories = List<String>.from(postData['categories']);
            final subscribedStudents = await _fetchSubscribedStudents(postCategories);
            for (final studentEmail in subscribedStudents) {
              _sendNotification(change.doc, studentEmail);
            }
            // Update the post document to indicate that notification has been sent
            change.doc.reference.update({'notificationSent': true});
          }
        }
      }
    });
  }

  Future<void> _sendNotification(DocumentSnapshot post, String studentEmail) async {
    final postData = post.data() as Map<String, dynamic>;
    _showNotification(
      postData['title'] ?? 'New Post',
      postData['description'] ?? 'Check it out!',
    );
  }



  Future<List<String>> _fetchSubscribedStudents(
      List<String> postCategories) async {
    final subscribedStudents = <String>[];
    for (final category in postCategories) {
      final studentsSnapshot = await _firestore
          .collection('students')
          .where('categories', arrayContains: category)
          .get();
      final studentEmails = studentsSnapshot.docs
          .map((doc) => doc['email'] as String)
          .toList();
      subscribedStudents.addAll(studentEmails);
    }
    return subscribedStudents.toSet().toList();
  }


}
