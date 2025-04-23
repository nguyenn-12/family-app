//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:family/pages/otp_verification.dart';
// import 'package:family/services/mail_service.dart';
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
//   DateTime? _selectedDob;
//   String? _selectedGender;
//   bool _isSendingOtp = false;
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2000),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDob = picked;
//       });
//     }
//   }
//
//   Future<void> _onSignUp() async {
//     if (_formKey.currentState!.validate() && _selectedDob != null && _selectedGender != null) {
//       setState(() {
//         _isSendingOtp = true;
//       });
//
//       final otp = OtpService.generateOtp();
//       await OtpService.sendOtpEmail(_emailController.text.trim(), otp);
//
//       setState(() {
//         _isSendingOtp = false;
//       });
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => OtpVerification(
//             email: _emailController.text.trim(),
//             name: _nameController.text.trim(),
//             password: _passwordController.text.trim(),
//             dob: _selectedDob!,
//             gender: _selectedGender!,
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please complete all fields!')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff1e2dd),
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 40),
//             Image.asset('assets/images/app-logo.png', height: 100),
//             const SizedBox(height: 20),
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(32),
//                     topRight: Radius.circular(32),
//                   ),
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: ListView(
//                     children: [
//                       Center(
//                         child: Text(
//                           'Sign Up',
//                           style: GoogleFonts.poppins(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       _buildInputField(_nameController, 'Enter Name', Icons.person),
//                       const SizedBox(height: 16),
//                       _buildInputField(_emailController, 'Enter Email', Icons.email, isEmail: true),
//                       const SizedBox(height: 16),
//                       _buildInputField(_passwordController, 'Enter Password', Icons.lock, obscureText: true),
//                       const SizedBox(height: 16),
//                       _buildInputField(_confirmPasswordController, 'Confirm Password', Icons.lock, obscureText: true),
//                       const SizedBox(height: 16),
//                       _buildDatePicker(),
//                       const SizedBox(height: 16),
//                       _buildGenderDropdown(),
//                       const SizedBox(height: 32),
//                       ElevatedButton(
//                         onPressed: _isSendingOtp ? null : _onSignUp,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF329B80),
//                           minimumSize: const Size(double.infinity, 52),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                         child: _isSendingOtp
//                             ? const CircularProgressIndicator(color: Colors.white)
//                             : Text(
//                           'Send OTP',
//                           style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Already have an account?',
//                             style: GoogleFonts.poppins(
//                               fontSize: 15,
//                               color: Colors.black54,
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: Text(
//                               'Sign in',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 15,
//                                 color: Color(0xFF329B80),
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInputField(TextEditingController controller, String hintText, IconData icon,
//       {bool obscureText = false, bool isEmail = false}) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       validator: (value) {
//         if (value == null || value.isEmpty) return 'Please fill $hintText';
//         if (isEmail && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Invalid email';
//         if (hintText == 'Confirm Password' && value != _passwordController.text) return 'Passwords do not match';
//         return null;
//       },
//       style: GoogleFonts.poppins(),
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon),
//         hintText: hintText,
//         filled: true,
//         fillColor: const Color(0xFFF1F1F1),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDatePicker() {
//     return GestureDetector(
//       onTap: _selectDate,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF1F1F1),
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.calendar_today),
//             const SizedBox(width: 16),
//             Text(
//               _selectedDob == null ? 'Date of Birth' : _selectedDob!.toLocal().toString().split(' ')[0],
//               style: GoogleFonts.poppins(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGenderDropdown() {
//     return DropdownButtonFormField<String>(
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: const Color(0xFFF1F1F1),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide.none,
//         ),
//       ),
//       value: _selectedGender,
//       hint: Text('Gender', style: GoogleFonts.poppins()),
//       onChanged: (value) {
//         setState(() {
//           _selectedGender = value;
//         });
//       },
//       items: ['Male', 'Female', 'Other'].map((gender) {
//         return DropdownMenuItem<String>(
//           value: gender,
//           child: Text(gender, style: GoogleFonts.poppins()),
//         );
//       }).toList(),
//       validator: (value) => value == null ? 'Please select a gender' : null,
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:family/pages/otp_verification.dart';
import 'package:family/services/mail_service.dart';
import 'package:family/services/user_service.dart';


class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedDob;
  String? _selectedGender;
  bool _isSendingOtp = false;
  bool _emailExists = false;
  bool _isCheckingEmail = false;
  Timer? _debounce;


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }
  void _onEmailChanged(String email) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (email.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(email)) return;

      setState(() {
        _isCheckingEmail = true;
      });

      final exists = await UserService.checkEmailExists(email);

      setState(() {
        _isCheckingEmail = false;
        _emailExists = exists;
      });
    });
  }


  Future<void> _onSignUp() async {
    if (_formKey.currentState!.validate() && _selectedDob != null && _selectedGender != null) {
      setState(() {
        _isSendingOtp = true;
      });

      final otp = MailService.generateOtp();
      try {
        await MailService.sendOtpEmail(
          recipientEmail: _emailController.text.trim(),
          otpCode: otp,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerification(
              email: _emailController.text.trim(),
              name: _nameController.text.trim(),
              password: _passwordController.text.trim(),
              dob: _selectedDob!,
              gender: _selectedGender!,
              otp: otp,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send OTP. Please try again!')),
        );
      } finally {
        setState(() {
          _isSendingOtp = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1e2dd),
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
                      _buildInputField(_nameController, 'Enter Name', Icons.person),
                      const SizedBox(height: 16),
                      _buildInputField(
                        _emailController,
                        'Enter Email',
                        Icons.email,
                        isEmail: true,
                        onChanged: _onEmailChanged,
                        showEmailError: _emailExists,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(_passwordController, 'Enter Password', Icons.lock, obscureText: true),
                      const SizedBox(height: 16),
                      _buildInputField(_confirmPasswordController, 'Confirm Password', Icons.lock, obscureText: true),
                      const SizedBox(height: 16),
                      _buildDatePicker(),
                      const SizedBox(height: 16),
                      _buildGenderDropdown(),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isSendingOtp ? null : _onSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF329B80),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSendingOtp
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Send OTP',
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
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Sign in',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF329B80),
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
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller,
      String hintText,
      IconData icon, {
        bool obscureText = false,
        bool isEmail = false,
        ValueChanged<String>? onChanged,
        bool showEmailError = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please fill $hintText';
            if (isEmail && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Invalid email';
            if (hintText == 'Confirm Password' && value != _passwordController.text) return 'Passwords do not match';
            if (isEmail && showEmailError) return 'Email already exists';
            return null;
          },
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF1F1F1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 16),
            Text(
              _selectedDob == null ? 'Date of Birth' : _selectedDob!.toLocal().toString().split(' ')[0],
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F1F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      value: _selectedGender,
      hint: Text('Gender', style: GoogleFonts.poppins()),
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
      items: ['Male', 'Female', 'Other'].map((gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender, style: GoogleFonts.poppins()),
        );
      }).toList(),
      validator: (value) => value == null ? 'Please select a gender' : null,
    );
  }
}
