import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MailService {
  static String generateOtp() {
    final rng = Random();
    return (rng.nextInt(900000) + 100000).toString();
  }

  static Future<void> sendOtpEmail({
    required String recipientEmail,
    required String otpCode,
  }) async {
    final smtpServer = gmail(
      'nguyenquynhmai273uit@gmail.com', // 🔥 thay bằng Gmail của bạn
      'hynt cdob rlty hmji',    // 🔥 App password chứ không phải password login Gmail thường
    );

    final message = Message()
      ..from = Address('nguyenquynhmai273uit@gmail.com', 'Family App') // 👈 đổi tên app nếu muốn
      ..recipients.add(recipientEmail)
      ..subject = 'Your OTP Code'
      ..text = 'Your OTP code is: $otpCode'
      ..html = '<h3>Your OTP code is: <b>$otpCode</b></h3>';

    try {
      await send(message, smtpServer);
      print('✅ OTP email sent successfully!');
    } catch (e) {
      print('❌ Failed to send OTP: $e');
      rethrow;
    }
  }
  static Future<void> sendResetPasswordEmail({
    required String recipientEmail,
    required String newPassword,
  }) async {
    final smtpServer = gmail(
      'nguyenquynhmai273uit@gmail.com',
      'hynt cdob rlty hmji',
    );

    final message = Message()
      ..from = Address('nguyenquynhmai273uit@gmail.com', 'Family App')
      ..recipients.add(recipientEmail)
      ..subject = 'Your New Password'
      ..text = 'Your new password is: $newPassword'
      ..html = '<h3>Your new password is: <b>$newPassword</b></h3>';

    try {
      await send(message, smtpServer);
      print('✅ Reset password email sent successfully!');
    } catch (e) {
      print('❌ Failed to send reset password email: $e');
      rethrow;
    }
  }

}
