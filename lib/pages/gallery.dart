import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:family/services/image_service.dart';
import 'package:family/models/images.dart';
import 'package:family/pages/image_details.dart';
import 'package:image_picker/image_picker.dart';
import 'package:family/providers/user_provider.dart';

class GalleryPage extends StatefulWidget {
  //final UserModel user;
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late Future<List<ImageModel>> _imagesFuture;
  List<ImageModel> _allImages = [];
  List<ImageModel> _filteredImages = [];

  String? selectedMonth;
  String? selectedYear;
  late final currentUser;

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 15;


  final List<String> months = List.generate(12, (index) => '${index + 1}');
  final List<String> years = List.generate(10, (index) => '${DateTime.now().year - index}');

  @override
  void initState() {
    super.initState();
    //currentUser = widget.user;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserProvider>(context, listen: false);
      currentUser = provider.user;
      _loadImages(refresh: true);
    });
    //_loadImages(refresh: true); // Bắt đầu bằng refresh để khởi tạo _allImages
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        _loadImages(); // Tải thêm ảnh khi gần chạm cuối
      }
    });
  }

  void _loadImages({bool refresh = false}) {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore || _isLoadingMore) return;

    final familyCode = currentUser.familyCode;
    if (familyCode == null) return;

    _isLoadingMore = true;

    ImageService.fetchImagesByFamilyCode(familyCode, page: _currentPage, pageSize: _pageSize).then((images) {
      if (!mounted) return;
      setState(() {
        if (refresh) {
          _allImages = images;
        } else {
          _allImages.addAll(images);
        }
        _filteredImages = List.from(_allImages); // reset filter nếu cần

        if (images.length < _pageSize) _hasMore = false;
        _currentPage++;
      });
    }).whenComplete(() => _isLoadingMore = false);
  }


  void _applyFilters() {
    DateTime? startDate;
    DateTime? endDate;

    final now = DateTime.now();
    final int? year = selectedYear != null ? int.tryParse(selectedYear!) : null;
    final int usedYear = year ?? now.year;

    if (selectedMonth != null) {
      final int? month = int.tryParse(selectedMonth!);
      if (month != null) {
        startDate = DateTime(usedYear, month, 1);
        endDate = DateTime(usedYear, month + 1, 1).subtract(const Duration(seconds: 1));
      }
    } else if (year != null) {
      startDate = DateTime(year, 1, 1);
      endDate = DateTime(year, 12, 31, 23, 59, 59);
    }

    setState(() {
      _filteredImages = _allImages.where((img) {
        final imgDate = img.time;
        if (startDate != null && endDate != null) {
          return imgDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
              imgDate.isBefore(endDate.add(const Duration(seconds: 1)));
        }
        return true;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      selectedMonth = null;
      selectedYear = null;
      _filteredImages = _allImages;
    });
  }

  final ImagePicker _picker = ImagePicker();


  void _showUploadDialog() {
    String description = '';
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.infinity,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header: nút Publish
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (selectedImage != null) {

                                final familyCode = currentUser.familyCode;
                                if (familyCode == "") {
                                  print("No family code, can't add image.");
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: Text(
                                          "You must join a family to share your pictures.",
                                          textAlign: TextAlign.center,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        actions: [
                                          Center(
                                            child: TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: Text("OK"),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return;
                                }

                                Navigator.pop(context);
                                await _uploadImageToImgurAndFirestore(
                                    selectedImage!, description);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF329B80),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Share'),
                          ),
                        ],
                      ),
                    ),

                    // Vùng nhập mô tả
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            hintText: 'What are you thinking?',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) => description = value,
                        ),
                      ),
                    ),

                    // Hiển thị ảnh nếu có chọn
                    if (selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(File(selectedImage!.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Nút chọn ảnh từ thư viện
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final image = await _picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setState(() => selectedImage = image);
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Choose from Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFA57BE4),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(40),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }




  Future<void> _uploadImageToImgurAndFirestore(XFile image, String description) async {
    try {
      final bytes = await image.readAsBytes();
      final familyCode = currentUser.familyCode;
      final uploadedBy = currentUser.email;
      await ImageService.uploadImageAndSaveToFirestore(
        imageBytes: bytes,
        description: description,
        uploadedBy: uploadedBy,
        familyCode: familyCode,
      );
      if (!mounted) return;
      _loadImages(refresh: true);

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 100,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFECE8EF),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: Text(
                          (selectedMonth == null && selectedYear == null)
                              ? 'All'
                              : '${selectedMonth ?? ''}/${selectedYear ?? '2025'}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF474649),
                          ),
                            textAlign: TextAlign.center,
                        ),
                        ),
                        if (selectedMonth != null || selectedYear != null)
                          TextButton(
                            onPressed: _resetFilters,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              minimumSize: const Size(0, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: Color(0xFF474142), fontSize: 16),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        DropdownButton<String>(
                          hint: const Text("Month"),
                          value: selectedMonth,
                          items: months.map((month) {
                            return DropdownMenuItem(
                              value: month,
                              child: Text(month),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMonth = value;
                              _applyFilters();
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          hint: const Text("Year"),
                          value: selectedYear,
                          items: years.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value;
                              _applyFilters();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                          onRefresh: () async {
                          _loadImages(refresh: true);
                            },
                  child: _filteredImages.isEmpty
                    ? const Center(child: Text('No images shared yet.'))
                    : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredImages.length + (_hasMore ? 1 : 0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      if (index >= _filteredImages.length) {
                        // Hiển thị loading ở cuối nếu còn ảnh để tải
                        return const Center(child: CircularProgressIndicator());
                      }

                      final image = _filteredImages[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageDetailsPage(image: image),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              image.imageURL,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              )
              ),
            ],
      ),

      floatingActionButton: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: Color(0xFF329B80),
          borderRadius: BorderRadius.circular(40),
        ),
        child: FloatingActionButton(
          onPressed: _showUploadDialog,
          backgroundColor: Color(0xFF329B80),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(Icons.add, size: 40, color: Colors.white),
        ),
      ),
    );
  }
}
