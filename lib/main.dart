import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'providers/user_provider.dart';
import 'pages/signin.dart';
import 'pages/signup.dart';
import 'pages/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Tạo và load UserProvider
  final userProvider = UserProvider();
  await userProvider.loadUserFromStorage(); // load nếu có user lưu cục bộ

  runApp(
    ChangeNotifierProvider(
      create: (_) => userProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        // Thêm route cho MainScreen nếu bạn dùng named routing
      },
    );
  }
}
