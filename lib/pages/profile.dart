
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:family/pages/edit_profile.dart';
import 'package:family/models/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family/services/family_service.dart';
import 'package:family/services/user_service.dart';
import 'package:family/models/family.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserModel currentUser;
  late bool hasFamily;
  List<UserModel> members = [];
  FamilyModel? createdFamily;

  final GlobalKey avatarKey = GlobalKey();
  final TextEditingController _familyCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    hasFamily = currentUser.familyCode.isNotEmpty;
    _familyCodeController.text = currentUser.familyCode;
    _loadFamilyMembers(); // Load members on start
  }

  Future<void> _loadFamilyMembers() async {
    if (hasFamily) {
      final fetchedRaw = await FamilyService.fetchFamilyMembers(currentUser.familyCode);
      final familyInfo = await FamilyService.getFamilyById(currentUser.familyCode);
      final parsed = fetchedRaw.map((map) => UserModel.fromMap(map)).toList();
      setState(() {
        members = parsed;
        createdFamily = familyInfo;
      });
    }
  }

  Future<void> _createFamily() async {
    try {
      // Tạo family mới bằng FamilyService
      final familyId = await FamilyService.createFamily(currentUser.id);

      // Cập nhật familyCode cho user hiện tại
      await UserService.updateFamilyCode(currentUser.id, familyId);

      setState(() {
        currentUser = currentUser.copyWith(familyCode: familyId);
        hasFamily = true;
        _familyCodeController.text = familyId;
        _loadFamilyMembers();
      });

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
                  currentUser.familyCode,
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
      debugPrint('Error creating family: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create family')
          ),
      );
    }
  }
  Future<void> _joinFamily() async {
    //TODO: implement join logic here
    final familyCode = _familyCodeController.text.trim();

    if (familyCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a family code")),
      );
      return;
    }

    final exists = await FamilyService.getFamilyById(familyCode);
    if (exists == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Family code not found")),
      );
      return;
    }
    await UserService.updateFamilyCode(currentUser.id, familyCode);
    await FamilyService.updateMemberCount(familyCode, 1);

    setState(() {
      currentUser = currentUser.copyWith(familyCode: familyCode);
      hasFamily = true;
      _familyCodeController.text = familyCode;
      _loadFamilyMembers();
    });

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

  Future<void> _leaveFamily() async {
    final familyId = currentUser.familyCode;

    // Giảm số lượng thành viên
    await FamilyService.updateMemberCount(familyId, -1);

    // Lấy thông tin family để kiểm tra người tạo
    final family = await FamilyService.getFamilyById(familyId);

    if (family != null && family.createdBy == currentUser.id) {
      // Lấy danh sách thành viên khác (không bao gồm currentUser)
      final allMembers = await FamilyService.fetchFamilyMembers(familyId);
      final otherMembers = allMembers.where((m) => m['id'] != currentUser.id).toList();

      if (otherMembers.isEmpty) {
        // Xoá family nếu không còn ai
        await FamilyService.deleteFamily(familyId);
      } else {
        // Gán người khác làm người tạo mới
        final newCreatorId = otherMembers.first['id'];
        await FamilyService.updateCreatedBy(familyId, newCreatorId);
      }
    }

    // Xóa familyCode của currentUser
    await UserService.updateFamilyCode(currentUser.id, "");

    setState(() {
      currentUser = currentUser.copyWith(familyCode: "");
      hasFamily = false;
      _familyCodeController.text = "";
      _loadFamilyMembers();
    });

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


  void _openEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage(user: currentUser)),
    );
    if (result != null && result is UserModel) {
      setState(() {
        currentUser = result;
        _loadFamilyMembers();
      });
    }
  }

  String _getCreatorName() {
    final creator = members.firstWhere(
          (u) => u.id == createdFamily?.createdBy,
      orElse: () => UserModel(
        id: '',
        email: '',
        name: 'Unknown',
        dob: DateTime.now(),
        pass: '',
        avatar: '',
        familyCode: '',
        gender: '',
      ),
    );
    return creator.name;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                        if (value == 0) {
                          _openEditProfile();
                        } else if (value == 1) {
                          const storage = FlutterSecureStorage();
                          await storage.delete(key: 'auth_token');
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      });
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      backgroundImage: currentUser.avatar.isNotEmpty ? NetworkImage(currentUser.avatar) : null,
                      child: currentUser.avatar.isEmpty ? const Icon(Icons.person, color: Color(0xFF007B8F)) : null,
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
                        Text(currentUser.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text("Have a nice day !", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  const Icon(Icons.notifications_none, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildReadOnlyField("Email", currentUser.email),
                  const SizedBox(height: 16),
                  _buildReadOnlyField("Date of Birth", DateFormat('yyyy-MM-dd').format(currentUser.dob)),
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
                              borderSide: const BorderSide(color: Color(
                                  0xFF4C4B4B)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if (hasFamily)
                        IconButton(
                          icon: const Icon(Icons.copy, color: Color(0xFF007B8F)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: currentUser.familyCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Copied!")),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: hasFamily ? null : _createFamily,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasFamily ? Colors.grey[300] : const Color(0xFF00C6A2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Create"),
                      ),
                      ElevatedButton(
                        onPressed: hasFamily ? null : _joinFamily,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasFamily ? Colors.grey[300] : const Color(0xFF007B8F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Join"),
                      ),
                      ElevatedButton(
                        onPressed: hasFamily ? _leaveFamily : null,
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
                  if (hasFamily)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("All Members (${members.length}): ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              final member = members[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.teal[100 * ((index % 7) + 1)],
                                  backgroundImage: member.avatar.isNotEmpty
                                      ? NetworkImage(member.avatar)
                                      : null,
                                  child: member.avatar.isEmpty
                                      ? const Icon(Icons.person, color: Colors.white)
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (createdFamily != null)
                          Row(
                            children: [
                              const Icon(Icons.verified_user, size: 18, color: Color(0xFF00C6A2)),
                              const SizedBox(width: 6),
                              Text(
                                "Created by: ${_getCreatorName()}",
                                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black54),
                              ),
                            ],
                          ),

                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, {bool enabled = true}) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF007B8F)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF007B8F)),
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
