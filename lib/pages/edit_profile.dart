import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:family/models/users.dart';
import 'package:family/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:family/providers/user_provider.dart';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController dobController;
  late TextEditingController passController;
  late UserModel currentUser;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user!;
    currentUser = user;
    nameController = TextEditingController(text: user.name);
    emailController = TextEditingController(text: user.email);
    dobController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(user.dob));
    passController = TextEditingController(text: user.pass);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    dobController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> _pickImageAndUpload() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      final bytes = await pickedFile.readAsBytes();
      // final base64Image = base64Encode(bytes);
      // final response = await http.post(
      //   Uri.parse("https://api.imgur.com/3/image"),
      //   headers: {"Authorization": "Client-ID 4a47796c6fc8864"},
      //   body: {"image": base64Image},
      // );
      //
      // final data = jsonDecode(response.body);
      // if (response.statusCode == 200 && data['success']) {
      //   final uploadedUrl = data['data']['link'];
      // 🟢 Gửi request multipart tới Cloudinary
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/db1dhw93x/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'family' // dùng preset unsigned
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'avatar.jpg',
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['secure_url'] != null) {
        final uploadedUrl = data['secure_url'];
        setState(() {
          currentUser = currentUser.copyWith(avatar: uploadedUrl);
        });
      } else {
        throw Exception("Imgur upload failed: ${data['data']['error']}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image upload failed. Please try again.")),
      );
    }
  }

  Future<void> _handleSaveProfile() async {
    final updatedUser = currentUser.copyWith(
      name: nameController.text,
      pass: passController.text,
      dob: DateFormat('yyyy-MM-dd').parse(dobController.text),
    );

    try {
      await UserService.updateUser(updatedUser);
      Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);

      if (!mounted) return;


      await _showDialog(
        title: "Notice",
        message: "Update your information successfully!",
        icon: const Icon(Icons.verified, color: Color(0xFF00C6A2), size: 40),
      );

      Navigator.pop(context, updatedUser);
    } catch (e) {
      if (!mounted) return;
      await _showDialog(
        title: "Notice",
        message: "Update failed, please try again.",
        icon: const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
      );
    }
  }

  Future<void> _showDialog({required String title, required String message, required Widget icon}) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(24),
        title: Row(children: [icon, const SizedBox(width: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
        content: Text(message, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C6A2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  InputDecoration _roundedInput(String label) => InputDecoration(
    labelText: label,
    floatingLabelStyle: const TextStyle(color: Color(0xFF007B8F)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF007B8F))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00C6A2), width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf8fd),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        //backgroundColor: const Color(0xFFA580D8),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF00C6A2),
                Color(0xFF007B8F),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
    ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(1), // Độ dày của viền
                  decoration: BoxDecoration(
                    color: Color(0xFF007B8F), // Màu viền
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    backgroundImage: currentUser.avatar.isNotEmpty ? NetworkImage(currentUser.avatar) : null,
                    child: currentUser.avatar.isEmpty
                        ? const Icon(Icons.person, size: 48, color: Color(0xFF007B8F))
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImageAndUpload,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.black26),
                      ),
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          TextField(controller: nameController, decoration: _roundedInput("Name")),
          const SizedBox(height: 20),
          TextField(controller: emailController, enabled: false, style: const TextStyle(color: Colors.black54), decoration: _roundedInput("Email address", )),
          const SizedBox(height: 20),
          TextField(
            controller: dobController,
            readOnly: true,
            decoration: _roundedInput("Date of Birth"),
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: currentUser.dob,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                dobController.text = DateFormat('yyyy-MM-dd').format(picked);
              }
            },
          ),
          const SizedBox(height: 20),
          TextField(controller: passController, obscureText: true, decoration: _roundedInput("Password")),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: currentUser.gender,
            decoration: _roundedInput("Gender"),
            items: ["Male", "Female", "Other"].map((gender) => DropdownMenuItem(value: gender, child: Text(gender))).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  currentUser = currentUser.copyWith(gender: value);
                });
              }
            },
          ),
          const SizedBox(height: 40),
          Center(
            child: SizedBox(
              width: 130,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSaveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C6A2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
