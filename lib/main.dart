// import 'package:family/pages/main_screen.dart';
// import 'package:family/pages/signup.dart';
// import 'package:flutter/material.dart';
// import 'package:family/pages/signin.dart';
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Family App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       // home: MainScreen(), // hoặc màn hình Login nếu bạn có login flow
//       // home: SignUp(),
//       home: SignIn(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'pages/signin.dart';
import 'pages/signup.dart'; // nhớ iFuture<void>t file Sasync ignUp bạn có
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SignIn(),
        '/signup': (context) => const SignUp(), // 🛠 Khai báo SignUp page ở đây
      },
    );
  }
}
