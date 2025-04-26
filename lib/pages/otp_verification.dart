import 'package:flutter/material.dart';
import 'package:family/services/mail_service.dart';
import 'package:family/services/user_service.dart';
import 'package:family/models/users.dart';
import 'main_screen.dart';
import '/pages/signin.dart';

class OtpVerification extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  final DateTime dob;
  final String gender;
  final String otp;

  const OtpVerification({
    Key? key,
    required this.email,
    required this.name,
    required this.password,
    required this.dob,
    required this.gender,
    required this.otp,
  }) : super(key: key);

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isVerifying = true;
    });

    if (_otpController.text.trim() == widget.otp) {
      final user = UserModel(
        id: '',
        email: widget.email,
        name: widget.name,
        dob: widget.dob,
        pass: widget.password,
        avatar: '',
        familyCode: '',
        gender: widget.gender,
      );

      await UserService.saveUser(user);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignIn()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP!')),
      );
    }

    setState(() {
      _isVerifying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Text('Enter the OTP sent to ${widget.email}', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: _isVerifying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
