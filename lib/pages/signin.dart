
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:family/pages/main_screen.dart';
import 'package:family/services/user_service.dart';
import 'package:family/services/mail_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:family/models/users.dart';
import 'package:provider/provider.dart';
import 'package:family/providers/user_provider.dart';


class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningIn = false;
  bool _loginFailed = false;



  Future<void> _onSignIn(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSigningIn = true;
        _loginFailed = false;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final isValid = await UserService.verifyUserLogin(email, password);

      setState(() {
        _isSigningIn = false;
        _loginFailed = !isValid;

      });

      if (isValid) {
        final userModel = await UserService.fetchUser(email);
        if (userModel != null) {
          Provider.of<UserProvider>(context, listen: false).setUser(userModel);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      }
    }
  }
  Future<void> _onGoogleSignIn(BuildContext context) async {
    try {
      await GoogleSignIn().signOut(); // force choose account
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final email = user.email ?? '';
        final name = user.displayName ?? '';
        final photo = user.photoURL ?? '';

        final exists = await UserService.checkEmailExists(email);
        if (!exists) {
          final userModel = UserModel(
            id: '',
            email: email,
            name: name,
            dob: DateTime.now(), // default, user can update later
            pass: '',
            avatar: photo,
            familyCode: '',
            gender: 'Other',
          );
          await UserService.saveUser(userModel);
        }

        final userModel = await UserService.fetchUser(email);
        if (userModel != null) {
          Provider.of<UserProvider>(context, listen: false).setUser(userModel);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      }
    } catch (e) {
      print('Google Sign-In failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed')),
      );
    }
  }

  void _onForgotPassword(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    final exists = await UserService.checkEmailExists(email);
    if (!exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email not found!')),
      );
      return;
    }

    final newPass = _generateRandomPassword();
    await UserService.updatePassword(email, newPass);
    await MailService.sendResetPasswordEmail(recipientEmail: email, newPassword: newPass);


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New password has been sent to your email')),
    );
  }

  String _generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length]).join();
  }

  void _onSignUp(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FD),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/app-logo.png',
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Family App',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Image.asset(
                    'assets/images/login_illustration.png',
                    height: 180,
                  ),
                  const SizedBox(height: 32),
                  // ✏️ Email Input
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return 'Invalid email format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // ✏️ Password Input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  if (_loginFailed) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Incorrect email or password!',
                            style: TextStyle(
                              color: Color(0xFFB71C1C),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: TextButton(
                            onPressed: () => _onForgotPassword(context),
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Color(0xFF329B80),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    )

                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _onSignIn(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: const Color(0xFF329B80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Sign in',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _onGoogleSignIn(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: Colors.black12),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      foregroundColor: Colors.black87,
                    ),
                    icon: Image.asset(
                      'assets/icons/google_icon.png',
                      height: 24,
                      width: 24,
                    ),
                    label: Text(
                      'Sign in with Google',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'or',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _onSignUp(context),
                        child: Text(
                          'Sign up',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Color(0xFF329B80),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
