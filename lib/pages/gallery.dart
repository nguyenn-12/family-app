import 'package:flutter/material.dart';
import 'package:family/services/image_service.dart';
import 'package:family/models/images.dart';
import 'package:family/pages/image_details.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late Future<List<ImageModel>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _imagesFuture = ImageService.fetchImagesByFamilyCode('12345');
  }

  @override
  Widget build(BuildContext context) {
    print('GalleryPage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Gallery'),
        backgroundColor: const Color(0xFF329B80),
      ),
      body: FutureBuilder<List<ImageModel>>(
        future: _imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading images.'));
          }

          final images = snapshot.data ?? [];

          if (images.isEmpty) {
            return const Center(child: Text('No images shared yet.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3 / 4,
            ),
            itemBuilder: (context, index) {
              final image = images[index];
              print('Image URL: ${image.imageURL}');
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
                    borderRadius: BorderRadius.circular(12),
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
                ),

              );
            },
          );
        },
      ),
    );
  }
}
