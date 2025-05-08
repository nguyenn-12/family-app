
import 'package:family/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'providers/user_provider.dart';
import 'providers/unread_provider.dart';
import 'pages/signin.dart';
import 'pages/signup.dart';
import 'pages/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showNotification(message);
}

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'Your Channel Name',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? '',
    message.notification?.body ?? '',
    notificationDetails,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //
  final userProvider = UserProvider();
  await userProvider.loadUserFromStorage();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
  InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(create: (_) => UnreadProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  String? token;
  @override
  void initState() {
    super.initState();

    // Khi app đang mở
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Foreground: ${message.notification?.title}');
      _showNotification(message);
    });

    // Lấy token để gửi test từ Firebase Console
    FirebaseMessaging.instance.getToken().then((value) {
      print('📲 FCM Token: $value');
      setState(() {
        token = value;
      });
    });

    // Khi app được mở bằng cách nhấn vào thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Bạn có thể điều hướng hoặc xử lý khác ở đây nếu muốn
      debugPrint('Notification clicked: ${message.notification?.title}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Family App',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: user != null ? const MainScreen() : const SignIn(),
      routes: {
        '/signup': (context) => const SignUp(),
      },
    );
  }
}