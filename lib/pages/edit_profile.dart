
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:family/models/users.dart';
import 'package:family/services/user_service.dart';


class EditProfilePage extends StatefulWidget {
  final UserModel user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController dobController;
  late TextEditingController passController;
  String selectedGender = "";
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.user.email);
    nameController = TextEditingController(text: widget.user.name);
    dobController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.user.dob));
    passController = TextEditingController(text: widget.user.pass);
    selectedGender = widget.user.gender;
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  InputDecoration _roundedInput(String label) => InputDecoration(
    labelText: label,
    floatingLabelStyle: const TextStyle(color: Color(0xFF007B8F)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF007B8F)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF00C6A2), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  );

  UserModel _buildUpdatedUser() {
    return widget.user.copyWith(
      email: emailController.text,
      name: nameController.text,
      dob: DateFormat('yyyy-MM-dd').parse(dobController.text),
      pass: passController.text,
      avatar: _avatarFile?.path ?? widget.user.avatar,
      gender: selectedGender,
    );
  }

  Future<void> _showDialog({
    required String title,
    required String message,
    required Widget icon,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(24),
        title: Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
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
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Future<void> _handleSaveProfile() async {
    final updatedUser = _buildUpdatedUser();

    try {
      await UserService.updateUser(updatedUser);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf8fd),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edit Profile', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFFA580D8),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: _avatarFile != null
                      ? CircleAvatar(
                    radius: 48,
                    backgroundImage: FileImage(_avatarFile!),
                  )
                      : (widget.user.avatar.isNotEmpty
                      ? CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(widget.user.avatar),
                  )
                      : const Icon(Icons.person, size: 48, color: Color(0xFF007B8F))),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: pickImage,
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
          TextField(
            controller: nameController,
            decoration: _roundedInput("Name"),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: emailController,
            decoration: _roundedInput("Email address"),
            enabled: false,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: dobController,
            readOnly: true,
            decoration: _roundedInput("Date of Birth"),
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: widget.user.dob,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                dobController.text = DateFormat('yyyy-MM-dd').format(picked);
              }
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: passController,
            obscureText: true,
            decoration: _roundedInput("Password"),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedGender,
            decoration: _roundedInput("Gender"),
            items: ["Male", "Female", "Other"].map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedGender = value;
                });
              }
            },
          ),
          const SizedBox(height: 40),
          Center(
            child: SizedBox(
              width: 130,
              height: 50,
              child:
                ElevatedButton(
                  onPressed: _handleSaveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C6A2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),

                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            )
          )
        ],
      ),
    );
  }
}
