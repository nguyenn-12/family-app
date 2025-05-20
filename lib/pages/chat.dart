
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:family/pages/chat_bubble.dart';
import 'package:family/services/image_service.dart';
import 'package:family/models/users.dart';
import 'package:provider/provider.dart';
import 'package:family/providers/user_provider.dart';
import 'package:family/utils/read_helper.dart';

class ChatPage extends StatefulWidget {
  final VoidCallback? onGoToProfile;

  const ChatPage({super.key, this.onGoToProfile});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottomButton = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;
  late UserModel currentUser;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      // Nếu người dùng cuộn lên xa khỏi đáy, hiển thị nút mũi tên xuống
      final isAtBottom = _scrollController.offset <= 100;
      if (isAtBottom != !_showScrollToBottomButton) {
        setState(() {
          _showScrollToBottomButton = !isAtBottom;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    currentUser = user;

    if (currentUser.familyCode.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.group_off, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "You don't have any family yet.\nJoin or Create a family to use the Chat Room.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C6A2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  widget.onGoToProfile?.call();
                },
                child: const Text("Create", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('families')
                      .doc(currentUser.familyCode)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      itemCount: docs.length,
                      itemBuilder: (ctx, i) {
                        final docId = docs[i].id;
                        final data = docs[i].data() as Map<String, dynamic>;
                        final isMe = data['senderId'] == currentUser.id;

                        markMessageAsRead(
                          familyCode: currentUser.familyCode,
                          messageId: docId,
                          userId: currentUser.id,
                        );

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: ChatBubble(
                            isMe: isMe,
                            text: data['text'],
                            imageUrl: data['imageUrl'],
                            senderName: data['senderName'] ?? 'Unknown',
                            avatarUrl: data['avatarUrl'],
                            timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedImageFile != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImageFile!,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedImageFile = null),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: "Type a message...",
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.image, color: Colors.black54),
                                onPressed: pickImageForPreview,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.send, size: 16, color: Colors.black54),
                                  onPressed: () => handleSend(),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showScrollToBottomButton)
            Positioned(
              bottom: 70,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: _scrollToBottom,
                  backgroundColor: Colors.grey[100],
                  child: const Icon(Icons.arrow_downward, color: Colors.black54),
                ),
              )
            ),
        ],
      )
    );
  }

  Future<void> sendMessage({String? text, String? imageUrl}) async {
    if ((text == null || text.trim().isEmpty) && imageUrl == null) return;

    await FirebaseFirestore.instance
        .collection('families')
        .doc(currentUser.familyCode)
        .collection('messages')
        .add({
      'senderId': currentUser.id,
      'senderName': currentUser.name,
      'avatarUrl': currentUser.avatar,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'readBy': [currentUser.id],
    });

    _controller.clear();
    _scrollToBottom();
  }

  Future<void> pickImageForPreview() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImageFile = File(picked.path);
      });
    }
  }

  Future<void> handleSend() async {
    String? imageUrl;

    if (_selectedImageFile != null) {
      final bytes = await _selectedImageFile!.readAsBytes();

      await ImageService.uploadImageAndSaveToFirestore(
        imageBytes: bytes,
        description: "",
        uploadedBy: currentUser.email,
        familyCode: currentUser.familyCode,
      );

      // final response = await http.post(
      //   Uri.parse('https://api.imgur.com/3/image'),
      //   headers: {
      //     'Authorization': 'Client-ID 4a47796c6fc8864',
      //   },
      //   body: {
      //     'image': base64Encode(bytes),
      //   },
      // );
      //
      // final data = jsonDecode(response.body);
      // imageUrl = data['data']['link'];
      // TODO: Upload lên Cloudinary
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/db1dhw93x/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'family' //
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'chat_image.jpg',
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        imageUrl = data['secure_url'];
      } else {
        print('❌ Upload failed: ${response.body}');
        return;
      }
    }

    await sendMessage(
      text: _controller.text.trim().isEmpty ? null : _controller.text.trim(),
      imageUrl: imageUrl,
    );

    setState(() {
      _controller.clear();
      _selectedImageFile = null;
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}