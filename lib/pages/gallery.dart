import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:family/services/image_service.dart';
import 'package:family/models/images.dart';
import 'package:family/pages/image_details.dart';
import 'package:image_picker/image_picker.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late Future<List<ImageModel>> _imagesFuture;
  List<ImageModel> _allImages = [];
  List<ImageModel> _filteredImages = [];

  String? selectedMonth;
  String? selectedYear;

  final List<String> months = List.generate(12, (index) => '${index + 1}');
  final List<String> years = List.generate(10, (index) => '${DateTime.now().year - index}');

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    _imagesFuture = ImageService.fetchImagesByFamilyCode('12345');
    _imagesFuture.then((images) {
      if (!mounted) return;
      setState(() {
        _allImages = images;
        _filteredImages = images;
      });
    });
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
        return AlertDialog(
          title: const Text('Upload Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  selectedImage = await _picker.pickImage(source: ImageSource.gallery);
                },
                child: const Text('Choose from Gallery'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedImage != null) {
                  Navigator.pop(context);
                  await _uploadImageToImgurAndFirestore(selectedImage!, description);
                }
              },
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _uploadImageToImgurAndFirestore(XFile image, String description) async {
    try {
      final bytes = await image.readAsBytes();
      await ImageService.uploadImageAndSaveToFirestore(
        imageBytes: bytes,
        description: description,
        uploadedBy: "thaonguyen68161@gmail.com",
        familyCode: "12345",
      );
      if (!mounted) return;
      _loadImages(); // Load lại ảnh sau khi upload
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
      body: FutureBuilder<List<ImageModel>>(
        future: _imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading images.'));
          }

          return Column(
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
                child: _filteredImages.isEmpty
                    ? const Center(child: Text('No images shared yet.'))
                    : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredImages.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
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
                        child: GridTile(
                          footer: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  image.description,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'By: ${image.uploadedBy}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          child: Image.network(
                            image.imageURL,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadDialog,
        child: const Icon(Icons.add, size: 35, color: Colors.green,),
      ),

    );
  }
}
