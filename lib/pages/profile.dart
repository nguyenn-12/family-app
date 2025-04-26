import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'package:family/pages/edit_profile.dart';
import 'package:family/models/users.dart';
import 'package:family/models/families.dart';
import 'package:family/services/family_service.dart';
import 'package:family/services/user_service.dart';
import 'package:family/providers/user_provider.dart';
import 'package:family/pages/signin.dart';
import 'package:family/pages/notification.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  List<UserModel> members = [];
  FamilyModel? createdFamily;
  final TextEditingController _familyCodeController = TextEditingController();
  final GlobalKey avatarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null && user.familyCode.isNotEmpty) {
        _familyCodeController.text = user.familyCode;
        await _loadFamilyMembers(user.familyCode);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _familyCodeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null && user.familyCode.isNotEmpty) {
        _loadFamilyMembers(user.familyCode);
      }
    }
  }

  Future<void> _loadFamilyMembers(String familyCode) async {
    final fetchedRaw = await FamilyService.fetchFamilyMembers(familyCode);
    final familyInfo = await FamilyService.getFamilyById(familyCode);
    final parsed = fetchedRaw.map((map) => UserModel.fromMap(map)).toList();
    setState(() {
      members = parsed;
      createdFamily = familyInfo;
    });
  }

  Future<void> _refreshUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final updatedUser = await UserService.fetchUser(userProvider.user!.email);
    if (updatedUser != null) {
      userProvider.setUser(updatedUser);
      _familyCodeController.text = updatedUser.familyCode;
      if (updatedUser.familyCode.isNotEmpty) {
        await _loadFamilyMembers(updatedUser.familyCode);
      }
    }
  }

  Future<void> _createFamily(UserModel user) async {
    try {
      final familyId = await FamilyService.createFamily(user.id);
      await UserService.updateFamilyCode(user.id, familyId);
      await _refreshUser();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(24),
          title: Column(
            children: const [
              Icon(Icons.verified, color: Color(0xFF00C6A2), size: 40),
              SizedBox(height: 10),
              Text(
                  'Family Created Successfully!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Your family code:',
                  style: TextStyle(fontSize: 16, color: Colors.black54)
              ),
              const SizedBox(height: 8),
              SelectableText(
                  familyId,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF007B8F)
                  )
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C6A2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                child: Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("Error creating family: $e");
    }
  }

  Future<void> _joinFamily(UserModel user) async {
    final code = _familyCodeController.text.trim();
    if (code.isEmpty) return;

    final exists = await FamilyService.getFamilyById(code);
    if (exists == null) return;

    await UserService.updateFamilyCode(user.id, code);
    await FamilyService.updateMemberCount(code, 1);
    await _refreshUser();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        title: Row(
          children: const [
            Icon(Icons.hourglass_top_rounded, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            Text(
              "Pending Approval",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Your request to join the family has been sent.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const Text(
              "Please wait for approval!",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00C6A2),
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

  Future<void> _leaveFamily(UserModel user) async {
    final familyId = user.familyCode;
    await FamilyService.updateMemberCount(familyId, -1);

    final family = await FamilyService.getFamilyById(familyId);
    if (family != null && family.createdBy == user.id) {
      final others = (await FamilyService.fetchFamilyMembers(familyId))
          .where((m) => m['id'] != user.id)
          .toList();
      if (others.isEmpty) {
        await FamilyService.deleteFamily(familyId);
      } else {
        await FamilyService.updateCreatedBy(familyId, others.first['id']);
      }
    }

    await UserService.updateFamilyCode(user.id, "");
    await _refreshUser();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(24),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.redAccent, size: 40),
            SizedBox(width: 10),
            Text(
              'Notice',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Text(
          "You have left the family.",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00C6A2),
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

  void _showInfoDialog(String message, String code) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: code.isNotEmpty
            ? SelectableText("Your family code: $code")
            : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _openEditProfile(UserModel user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage()),
    );
    final updatedUser = Provider.of<UserProvider>(context, listen: false).user;
    if (updatedUser != null && updatedUser.familyCode.isNotEmpty) {
      setState(() {
        _familyCodeController.text = updatedUser.familyCode;
      });
      await _loadFamilyMembers(updatedUser.familyCode);
    }
  }

  Future<void> _logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'current_user');
    Provider.of<UserProvider>(context, listen: false).setUser(null);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignIn()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) return const Center(child: CircularProgressIndicator());
    final hasFamily = user.familyCode.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(user),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildReadOnlyField("Email", user.email),
                  const SizedBox(height: 16),
                  _buildReadOnlyField("Date of Birth", DateFormat('yyyy-MM-dd').format(user.dob)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _familyCodeController,
                          enabled: !hasFamily,
                          decoration: InputDecoration(
                            labelText: "Family Code",
                            labelStyle: const TextStyle(color: Color(0xFF007B8F)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF007B8F)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF007B8F)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if (hasFamily)
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: user.familyCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Copied!")),
                            );
                          },
                        )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: hasFamily ? null : () => _createFamily(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasFamily ? Colors.grey[300] : const Color(0xFF00C6A2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Create"),
                      ),
                      ElevatedButton(
                        onPressed: hasFamily ? null : () => _joinFamily(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasFamily ? Colors.grey[300] : const Color(0xFF007B8F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Join"),
                      ),
                      ElevatedButton(
                        onPressed: hasFamily ? () => _leaveFamily(user) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB880CC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Leave"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (hasFamily) _buildFamilyInfo(user),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C6A2), Color(0xFF007B8F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              key: avatarKey,
              onTap: () async {
                final RenderBox renderBox = avatarKey.currentContext!.findRenderObject() as RenderBox;
                final Offset offset = renderBox.localToGlobal(Offset.zero);
                await showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                          offset.dx,
                          offset.dy + renderBox.size.height,
                          offset.dx + renderBox.size.width,
                          offset.dy,
                        ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  items: [
                    PopupMenuItem<int>(value: 0, child: Row(children: const [Icon(Icons.edit, size: 18, color: Colors.black54), SizedBox(width: 6), Text("Edit Profile", style: TextStyle(fontSize: 14))])),
                    PopupMenuItem<int>(value: 1, child: Row(children: const [Icon(Icons.logout, size: 18, color: Colors.black54), SizedBox(width: 6), Text("Logout", style: TextStyle(fontSize: 14))])),
                  ],
                ).then((value) async {
                  if (value == 0) _openEditProfile(user);
                  if (value == 1) _logout();
                });
                },
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                backgroundImage: user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
                child: user.avatar.isEmpty ? const Icon(Icons.person, color: Color(0xFF007B8F)) : null,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(DateFormat('EEEE, MMMM d yyyy').format(DateTime.now()), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  const Text("Welcome", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text("Have a nice day !", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            //const Icon(Icons.notifications_none, color: Colors.white, size: 30),
            IconButton(
              icon: Icon(Icons.notifications_none, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                );
              },
            ),

          ],
        )
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      enabled: false,
      style: const TextStyle(color: Colors.black), // 👈 text màu đen
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF007B8F)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF007B8F)),
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF007B8F)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }


  Widget _buildFamilyInfo(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("All Members (${members.length})", style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: member.avatar.isNotEmpty ? NetworkImage(member.avatar) : null,
                  child: member.avatar.isEmpty ? const Icon(Icons.person) : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        if (createdFamily != null)
          Row(
            children: [
              const Icon(Icons.verified_user, size: 16),
              const SizedBox(width: 6),
              Text("Created by: ${_getCreatorName()}", style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
      ],
    );
  }

  String _getCreatorName() {
    final creator = members.firstWhere(
          (u) => u.id == createdFamily?.createdBy,
      orElse: () => UserModel(
        id: '', email: '', name: 'Unknown', dob: DateTime.now(),
        pass: '', avatar: '', familyCode: '', gender: '',
      ),
    );
    return creator.name;
  }
}
