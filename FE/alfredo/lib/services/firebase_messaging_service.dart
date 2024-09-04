import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api/alarm/alarm_api.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late final FlutterLocalNotificationsPlugin _localNotifications;
  final AlarmApi _alarmApi = AlarmApi();

  static String? deviceToken;

  FirebaseMessagingService() {
    _initLocalNotifications();
  }

  /// 로컬 알림 시스템을 초기화합니다.
  void _initLocalNotifications() {
    _localNotifications = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    _localNotifications.initialize(initializationSettings);
  }

  /// FCM 설정 및 로컬 알림 설정을 초기화합니다.
  Future<void> setupInteractions() async {
    // FCM 알림 권한을 요청합니다.
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true, // 알림 표시
      badge: true, // 앱 아이콘에 배지 표시
      sound: true, // 소리 알림
      provisional: false, // 임시 알림 비허용
    );

    print('사용자 권한 부여 상태: ${settings.authorizationStatus}');

    // FCM 토큰을 가져옵니다.
    deviceToken = await _messaging.getToken();
    // print('Firebase 메시징 토큰: $deviceToken');

    // 토큰이 있을 경우 서버로 전송

    // 포그라운드 상태에서 메시지 수신 리스너 등록
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // print('포그라운드에서 메시지 수신!');
      // print('메시지 데이터: ${message.data}');

      if (message.notification != null) {
        // print(
        //     '알림 포함 메시지: 제목: ${message.notification!.title}, 본문: ${message.notification!.body}');
        _showNotification(
            message.notification!.title, message.notification!.body);
      }
    });

    // 백그라운드 상태에서 메시지 처리 핸들러 설정
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 알림 클릭 시 루틴 화면으로 이동
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // print('sj Message clicked!');
      if (message.data['type'] == 'routine') {
        // print("routine sended");
        // Navigator가 context 밖에서 사용할 수 없기 때문에 NavigationService를 이용하거나, MyApp에서 라우트 설정을 통해 처리해야 합니다.
        // 아래 코드를 MyApp의 _firebaseMessagingBackgroundHandler로 이동합니다.
      }
    });
  }

  /// 포그라운드에서 알림을 표시합니다.
  Future _showNotification(String? title, String? body) async {
    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.high,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);
    await _localNotifications.show(0, title, body, notificationDetails);
  }

  /// 백그라운드 메시지를 처리합니다.
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // print("백그라운드 메시지 처리: 메시지 ID: ${message.messageId}");
    if (message.data.isNotEmpty) {
      // print("백그라운드 메시지 데이터: ${message.data}");
    }
    if (message.notification != null) {
      // print(
      //     "백그라운드 알림: 제목: ${message.notification!.title}, 본문: ${message.notification!.body}");
    }
  }
}
