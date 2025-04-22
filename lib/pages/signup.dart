// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:family/pages/otp_verification.dart';
//
// class SignUp extends StatefulWidget {
//   const SignUp({Key? key}) : super(key: key);
//
//   @override
//   State<SignUp> createState() => _SignUpState();
// }
//
// class _SignUpState extends State<SignUp> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//
//   bool _isCheckingEmail = false;
//   bool _emailExists = false;
//   Timer? _debounce;
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   Future<bool> _checkEmailExists(String email) async {
//     await Future.delayed(const Duration(milliseconds: 800));
//     if (email.contains('test')) {
//       return true;
//     }
//     return false;
//   }
//
//   void _onEmailChanged(String email) {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();
//
//     _debounce = Timer(const Duration(milliseconds: 500), () async {
//       if (email.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
//         return;
//       }
//
//       setState(() {
//         _isCheckingEmail = true;
//       });
//
//       final exists = await _checkEmailExists(email);
//
//       setState(() {
//         _isCheckingEmail = false;
//         _emailExists = exists;
//       });
//     });
//   }
//
//   Future<void> _onSignUp() async {
//     if (_formKey.currentState!.validate()) {
//       if (_emailExists) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('This email is already registered!')),
//         );
//         return;
//       }
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => OtpVerification(
//             email: _emailController.text.trim(),
//           ),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9F8FD),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           'Sign up new account',
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.black87),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               const SizedBox(height: 32),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Full Name',
//                   labelStyle: GoogleFonts.poppins(),
//                   border: const OutlineInputBorder(),
//                   prefixIcon: const Icon(Icons.person),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your name!';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   labelStyle: GoogleFonts.poppins(),
//                   border: const OutlineInputBorder(),
//                   prefixIcon: const Icon(Icons.email),
//                   suffixIcon: _isCheckingEmail
//                       ? const Padding(
//                     padding: EdgeInsets.all(10),
//                     child: SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   )
//                       : _emailExists
//                       ? const Icon(Icons.error, color: Colors.red)
//                       : null,
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 onChanged: _onEmailChanged,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
//                     return 'Invalid email format!';
//                   }
//                   if (_emailExists) {
//                     return 'This email is already registered!';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   labelStyle: GoogleFonts.poppins(),
//                   border: const OutlineInputBorder(),
//                   prefixIcon: const Icon(Icons.lock),
//                 ),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value == null || value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 decoration: InputDecoration(
//                   labelText: 'Confirm Password',
//                   labelStyle: GoogleFonts.poppins(),
//                   border: const OutlineInputBorder(),
//                   prefixIcon: const Icon(Icons.lock),
//                 ),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value != _passwordController.text) {
//                     return 'Passwords do not match';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 32),
//               ElevatedButton(
//                 onPressed: _onSignUp,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF329B80),
//                   minimumSize: const Size(double.infinity, 52),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 child: Text(
//                   'Sign up',
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Already have an account?',
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       color: Colors.black54,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () { Navigator.pop(context);},
//                     child: Text(
//                       'Sign in',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         color: Color(0xFF329B80),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:family/pages/otp_verification.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isCheckingEmail = false;
  bool _emailExists = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _checkEmailExists(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.contains('test')) {
      return true;
    }
    return false;
  }

  void _onEmailChanged(String email) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (email.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(email)) return;

      setState(() {
        _isCheckingEmail = true;
      });

      final exists = await _checkEmailExists(email);

      setState(() {
        _isCheckingEmail = false;
        _emailExists = exists;
      });
    });
  }

  Future<void> _onSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (_emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This email is already registered!')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerification(
            email: _emailController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1e2dd), // Nền vàng nhạt
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset('assets/images/app-logo.png', height: 100),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Center(
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Name
                      _buildInputField(
                        controller: _nameController,
                        hintText: 'Enter Name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Email
                      _buildInputField(
                        controller: _emailController,
                        hintText: 'Enter Email',
                        icon: Icons.email,
                        onChanged: _onEmailChanged,
                        suffix: _isCheckingEmail
                            ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                            : _emailExists
                            ? const Icon(Icons.error, color: Colors.red)
                            : null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'Invalid email format!';
                          }
                          if (_emailExists) {
                            return 'This email is already registered!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password
                      _buildInputField(
                        controller: _passwordController,
                        hintText: 'Enter Password',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Confirm Password
                      _buildInputField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm Password',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _onSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF329B80),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Login',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF329B80),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF1F1F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
