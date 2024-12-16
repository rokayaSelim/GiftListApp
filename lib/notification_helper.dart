import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class NotificationsHelper {
  // creat instance of fbm
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();


  // initialize notifications for this app or device
  Future<void> initNotifications() async {
    // Request permission to receive notifications
    await _firebaseMessaging.requestPermission();

    // Initialize Local Notifications
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(initSettings);

    // Get the device token
    String? deviceToken = await _firebaseMessaging.getToken();
    print("===================Device FirebaseMessaging Token====================");
    print(deviceToken);
    print("===================Device FirebaseMessaging Token====================");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("====Foreground Notification Received====");
      print("Message Title: ${message.notification?.title}");
      print("Message Body: ${message.notification?.body}");

      // Optionally show a local notification here
      _showLocalNotification(message);
    });
  }

// Show a local notification using flutter_local_notifications
  void _showLocalNotification(RemoteMessage message) {
    // You can integrate flutter_local_notifications here for better UI
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      _localNotificationsPlugin.show(
        notification.hashCode, // Notification ID
        notification.title,    // Notification Title
        notification.body,     // Notification Body
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // Channel ID
            'High Importance Notifications', // Channel Name
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }


  }


  // handle notifications when received
  void handleMessages(RemoteMessage? message) {
    if (message != null) {
      // navigatorKey.currentState?.pushNamed(NotificationsScreen.routeName, arguments: message);
      print("hello");
    }
  }
  // handel notifications in case app is terminated
  void handleBackgroundNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then((handleMessages));
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessages);
  }

  Future<String?> getAccessToken() async {
    final serviceAccountJson = {

      "type": "service_account",
      "project_id": "proj20p4322-d6f40",
      "private_key_id": "d233ee4b8f333e1f9f06835d8a7385ff1c2b30b1",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC9sXRnq0DKvJhM\nII0uXfi2ZXa8OkdDAtHkVl2VsgqInFrpBDTawII0Mzp6QhAKRe8B5Ct/lgeL7PhX\n/0WYHVW285Tobvn+nhX+ogmI4m5uXpEs3pMZdKs+i9VhDlsOD6W10P0/ap87mVrz\nwg//QnDE8CcovVKOA/AyJHJ1ZPriOQySAEWx7igqc8riZ7tpp6qugmm2Pn1xKZoS\nD772xFlH1GtBGpqSqNxEgbQlCYNCG5/vAPDkL8e4fco7tvspb5d/QUji7BTsjDLn\nqWr+EoXJ8fa411QVDV3mRWvYSZ+wPCwtNgtsYtM0Z+7oa2EOV/+DoC72fKPr/+Pj\nTWPsjNczAgMBAAECggEAIOlJa3UkbChVehvJsuo97RNkitrHo2I5XVb4rLCzsCkE\ngtome2+cB4d91Vlh5A5nHdpjC6NRkt7d5ZKWFgK87N2ND9i1Sg5OfZvKcLPsefyx\nTmoddnSuA0+KiWjOtn1TgFyOm7KZhuMgCxu33888toZ+HMzgJmCbi2+UZjbLanUz\n+ADsyvDgGzc6eOiKuWxaRe3tRtiK57BIFpK6kMTfS7AY2fFR8OACB0VgR91RVGJ8\n664qWBcI0YQQbHOI7GVbRNJQqFH6Xv6M08gEJeWsQYA3Vvre+gFgR+VcPIl3p0ga\nVL2xlMgh39cszGMIBtO1uTP91DG8Y7587xLGxacQUQKBgQDcbcgNbEDSYYUVwjK0\n5dLPSowz4X5X+7ksS3y6MPCBXRDu49b+M1hMeuBpi/2u2u4WFqnv4c0zYJzfh6Eb\nBlWdOX5CPuekLOlKHRNwgY69u7Wi+L/uvPo3+PycVLtmJU+xTxiRpT8yz5VJPkNC\n3HNrW9B7k5C/QPsQiNY1S7LnEQKBgQDcTfDxnR6Gcp2valMAGWGz4fKl+vvte5TW\n8ZeY4kDbULvXXdtcSrzYy6iS2jZA86B3tLhbDMc4jQmocXddn2iPeLAAcjlEIwzs\nI3cItMhETwV/NcIW/EaQiaeu7TYIFYznXji1+2EH8w50GQtBpaJUN3FXl0y8rtOY\nBswcJUYCAwKBgQCbskNzD7q9nzpUwyXz1r3Pw3VClA0c8mW6XtuL3FOU3HrAcliC\nlxvQcZ6fjs0yO9ud6IZCNTkvCBfmX7OxFglVE64V9r7BnSNvQRhhCHIdnD/RDGjt\npbgL3yf2+Hah0Mr4j8jn31PDfRKSeJMj3/j6pRCeqP29yZVM+YpsfLqyMQKBgQCr\nfeC5tF02u7IUAuhpg1iS9qg0nJPP4guS5q3jzPw/vTD8DYvc5DDtclvfNQ5WsU+Q\n35VDC0dptiB2hx0sPBLg3EnljwUVDVPZ3iGjHVdoFTtqMybLTcaAbSei+/S7hksR\nMD9lKjH2RjZSGcyxZYZfmGkajiSmHFGKXoA0yK8ekQKBgQCw4oAmZn5hI503KzXx\nk27Kiy8HJDttMNNZ+RHA3DRx9a+2uiO6dGsH6UExr6bXr3shoJ9shDav6Ai0B7iV\nKeTNJoIYYEa+vK4NOOgIi+oYnycQpFvcb+5Pp5q16gluuOrEArJAvyLIHRLwivjM\nVtRLCj24x9DVWL2HLAkwDitcZg==\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-5secu@proj20p4322-d6f40.iam.gserviceaccount.com",
      "client_id": "104373557557256290342",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-5secu%40proj20p4322-d6f40.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"


    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    try {
      http.Client client = await auth.clientViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
          scopes);

      auth.AccessCredentials credentials =
      await auth.obtainAccessCredentialsViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
          scopes,
          client);

      client.close();
      print(
          "Access Token: ${credentials.accessToken
              .data}"); // Print Access Token
      return credentials.accessToken.data;
    } catch (e) {
      print("Error getting access token: $e");
      return null;
    }
  }

  Map<String, dynamic> getBody({
    required String topic,
    required String title,
    required String body,
    required String userId,
    String? type,
  }) {
    return {
      "message": {
        "topic": topic,
        "notification": {"title": title, "body": body},
        "android": {
          "notification": {
            "notification_priority": "PRIORITY_MAX",
            "sound": "default"
          }
        },
        "apns": {
          "payload": {
            "aps": {"content_available": true}
          }
        },
        "data": {
          "type": type,
          "id": userId,
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        }
      }
    };
  }

  Future<void> sendNotifications({
    required String topic,
    required String title,
    required String body,
    required String userId,
    String? type,
  }) async {
    try {
      var serverKeyAuthorization = await getAccessToken();

      // change your project id
      const String urlEndPoint =
          "https://fcm.googleapis.com/v1/projects/proj20p4322-d6f40/messages:send";

      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $serverKeyAuthorization';

      var response = await dio.post(
        urlEndPoint,
        data: getBody(
          userId: userId,
          topic: topic,
          title: title,
          body: body,
          type: type ?? "message",
        ),
      );

      // Print response status code and body for debugging
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}