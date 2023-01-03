import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:social_media_app/app_services/notification_service.dart';
import 'package:social_media_app/utils/utility.dart';

@pragma('vm:entry-point')
int setNotificationId(String type) {
  switch (type) {
    case 'Chats':
      return 2;
    case 'Followers':
      return 3;
    case 'Likes':
      return 4;
    case 'Comments':
      return 5;
    case 'Follow Requests':
      return 6;
    case 'General Notifications':
      return 7;
    default:
      return 1;
  }
}

@pragma('vm:entry-point')
Priority setNotificationPriority(String type) {
  switch (type) {
    case 'Chats':
      return Priority.max;
    case 'Comments':
    case 'General Notifications':
      return Priority.high;
    case 'Follow Requests':
    case 'Followers':
    case 'Likes':
    default:
      return Priority.defaultPriority;
  }
}

@pragma('vm:entry-point')
bool setNotificationImportance(String type) {
  switch (type) {
    case 'Chats':
    case 'Comments':
    case 'General Notifications':
      return true;
    case 'Follow Requests':
    case 'Followers':
    case 'Likes':
    default:
      return false;
  }
}

@pragma('vm:entry-point')
Future<void> initializeFirebaseService() async {
  AppUtility.log('Initializing Firebase Service');

  await Firebase.initializeApp();

  var messaging = FirebaseMessaging.instance;

  await messaging.setAutoInitEnabled(true);

  var settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    AppUtility.log('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    AppUtility.log('User granted provisional permission');
  } else {
    AppUtility.log('User declined or has not accepted permission',
        tag: 'warning');
    return;
  }

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

  FirebaseMessaging.onMessage.listen(onMessage);

  // var initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  // if (initialMessage != null) {
  //   _handleMessage(initialMessage);
  // }
  // FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

  AppUtility.log('Firebase Service Initialized');

  // if (!notificationService.isInitialized) {
  //   await notificationService.initialize();
  // }
  //
  // var authService = AuthService.find;
  //
  // if (_networkService.isConnected == true) {
  //   await authService.getToken().then((token) async {
  //     if (token.isEmpty) {
  //       return;
  //     }
  //
  //     var isValid = await authService.validateLocalAuthToken();
  //
  //     if (isValid == false) {
  //       return;
  //     }
  //
  //     var tokenValid = await authService.validateToken(token);
  //     if (tokenValid == null) {
  //       return;
  //     } else {
  //       if (tokenValid == false) {
  //         notificationService.showNotification(
  //           title: 'Invalid Token',
  //           body: 'Token is invalid. Please login again.',
  //           priority: setNotificationPriority('General Notifications'),
  //           isImportant: setNotificationImportance('General Notifications'),
  //           id: setNotificationId('General Notifications'),
  //           channelId: 'General Notifications',
  //           channelName: 'General notifications',
  //         );
  //         return;
  //       }
  //     }
  //   });
  //
  //   if (authService.isLoggedIn) {
  //     var fcmToken = await authService.readFcmTokenFromLocalStorage();
  //     AppUtility.log('fcmToken: $fcmToken');
  //
  //     if (fcmToken.isEmpty) {
  //       await messaging.deleteToken();
  //       var token = await messaging.getToken();
  //       AppUtility.log('fcmToken: $token');
  //       await authService.saveFcmTokenToLocalStorage(token!);
  //       if (authService.token.isNotEmpty) {
  //         await authService.saveFcmToken(token);
  //       }
  //     }
  //
  //     messaging.onTokenRefresh.listen((newToken) async {
  //       AppUtility.log('fcmToken refreshed: $newToken');
  //       await authService.saveFcmTokenToLocalStorage(newToken);
  //       if (authService.token.isNotEmpty) {
  //         await authService.saveFcmToken(newToken);
  //       }
  //     });
  //   } else {
  //     await StorageService.remove("fcmToken");
  //     await messaging.deleteToken();
  //   }
  // }
}

// @pragma('vm:entry-point')
// void _handleMessage(RemoteMessage message) {
//   if (message.data['type'] == 'Chats') {
//     RouteManagement.goToChatDetailsView(
//       User(
//         id: isMe ? item.receiverId! : item.senderId!,
//         fname: isMe ? item.receiver!.fname : item.sender!.fname,
//         lname: isMe ? item.receiver!.lname : item.sender!.lname,
//         email: isMe ? item.receiver!.email : item.sender!.email,
//         uname: isMe ? item.receiver!.uname : item.sender!.uname,
//         avatar: isMe ? item.receiver!.avatar : item.sender!.avatar,
//         isPrivate: isMe ? item.receiver!.isPrivate : item.sender!.isPrivate,
//         followingStatus: isMe
//             ? item.receiver!.followingStatus
//             : item.sender!.followingStatus,
//         accountStatus:
//             isMe ? item.receiver!.accountStatus : item.sender!.accountStatus,
//         isVerified: isMe ? item.receiver!.isVerified : item.sender!.isVerified,
//         createdAt: isMe ? item.receiver!.createdAt : item.sender!.createdAt,
//         updatedAt: isMe ? item.receiver!.updatedAt : item.sender!.updatedAt,
//       ),
//     );
//     Navigator.pushNamed(
//       context,
//       '/chat',
//       arguments: ChatArguments(message),
//     );
//   }
// }

@pragma('vm:entry-point')
Future<void> onMessage(RemoteMessage message) async {
  AppUtility.log('Got a message whilst in the foreground!');
  AppUtility.log('Message data: ${message.data}');

  final notificationService = NotificationService();

  if (!notificationService.isInitialized) {
    await notificationService.initialize();
  }

  if (message.data.isNotEmpty) {
    var messageData = message.data;

    var title = messageData['title'];
    var body = messageData['body'];
    var imageUrl = messageData['image'];
    var type = messageData['type'];

    notificationService.showNotification(
      title: title ?? '',
      body: body ?? '',
      priority: setNotificationPriority(type),
      isImportant: setNotificationImportance(type),
      id: setNotificationId(type),
      largeIcon: imageUrl,
      channelId: type ?? 'General Notifications',
      channelName: type ?? 'General notifications',
    );
  }

  if (message.notification != null) {
    AppUtility.log(
        'Message also contained a notification: ${message.notification}');
  }
}

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  debugPrint("Handling a background message");
  debugPrint('Message data: ${message.data}');

  final notificationService = NotificationService();

  if (!notificationService.isInitialized) {
    await notificationService.initialize();
  }

  if (message.data.isNotEmpty) {
    var messageData = message.data;

    var title = messageData['title'];
    var body = messageData['body'];
    var imageUrl = messageData['image'];
    var type = messageData['type'];

    notificationService.showNotification(
      title: title ?? '',
      body: body ?? '',
      priority: setNotificationPriority(type),
      isImportant: setNotificationImportance(type),
      id: setNotificationId(type),
      largeIcon: imageUrl,
      channelId: type ?? 'General Notifications',
      channelName: type ?? 'General notifications',
    );
  }

  if (message.notification != null) {
    AppUtility.log(
        'Message also contained a notification: ${message.notification}');
  }
}