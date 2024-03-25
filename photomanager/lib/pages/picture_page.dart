import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class PicturePage extends StatelessWidget {
  final AssetEntity assetEntity;

  const PicturePage({super.key, required this.assetEntity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picture'),
      ),
      body: Center(
        child: Image(
          image: AssetEntityImageProvider(
            assetEntity,
            isOriginal: false,
            thumbnailSize: const ThumbnailSize.square(1000),
          ),
        ), // Display the selected image
      ),
    );
  }
}
