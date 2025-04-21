import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Đây là Gallery Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
