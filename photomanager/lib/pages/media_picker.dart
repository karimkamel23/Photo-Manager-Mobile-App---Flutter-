import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photomanager/pages/picture_page.dart';
import 'package:photomanager/services/media_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class MediaPicker extends StatefulWidget {
  final int maxCount;
  final RequestType requestType;
  const MediaPicker({
    super.key,
    required this.maxCount,
    required this.requestType,
  });

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetList = [];
  List<AssetEntity> selectedAssetList = [];

  void _requestPermission() async {
    // Check permission status
    PermissionStatus status = await Permission.photos.status;
    PermissionStatus status2 = await Permission.camera.status;

    // If permission is granted, continue
    if (status.isGranted && status2.isGranted) {
      return;
    }
    // If permission is not granted, request it
    else {
      // Request permission
      status = await Permission.photos.request();
      status2 = await Permission.camera.request();

      // If permission is granted, continue
      if (status.isGranted && status2.isGranted) {
        // Permission granted
        // You can proceed with your functionality here
      } else {
        // Permission denied
        // Handle the scenario where permission is denied
      }
    }
  }

  @override
  void initState() {
    _requestPermission();
    MediaService().loadAlbums(widget.requestType).then(
      (value) {
        setState(() {
          albumList = value;
          selectedAlbum = value[0];
        });
        MediaService().loadAssets(selectedAlbum!).then((value) {
          setState(() {
            assetList = value;
          });
        });
      },
    );
    super.initState();
  }

  Future<void> _openCamera() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      // Handle the captured image, if needed
      final savedImage = await ImageGallerySaver.saveFile(image.path);
      print('Image saved to: $savedImage');
    }

    // Trigger a reload of the photo grid
    setState(() {
      assetList = [];
    });

    MediaService().loadAlbums(widget.requestType).then(
      (value) {
        setState(() {
          albumList = value;
          selectedAlbum = value[0];
        });
        MediaService().loadAssets(selectedAlbum!).then((value) {
          setState(() {
            assetList = value;
          });
        });
      },
    );
  }

  void _deleteSelectedAssets() async {
    // Get the asset ids to delete
    List<String> assetIdsToDelete =
        selectedAssetList.map((asset) => asset.id).toList();

    // Delete assets using PhotoManager
    for (String assetId in assetIdsToDelete) {
      await PhotoManager.editor.deleteWithIds([assetId]);
    }

    // Clear the selectedAssetList
    setState(() {
      selectedAssetList.clear();
    });
    // Trigger a reload of the photo grid
    setState(() {
      assetList = [];
    });

    MediaService().loadAlbums(widget.requestType).then(
      (value) {
        setState(() {
          albumList = value;
          selectedAlbum = value[0];
        });
        MediaService().loadAssets(selectedAlbum!).then((value) {
          setState(() {
            assetList = value;
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _openCamera,
          tooltip: 'Open Camera',
          backgroundColor: Colors.grey.shade800,
          foregroundColor: Colors.white,
          elevation: 4.0,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.camera_alt,
          ),
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          title: DropdownButton<AssetPathEntity>(
            value: selectedAlbum,
            onChanged: (AssetPathEntity? value) {
              setState(() {
                selectedAlbum = value;
              });
              MediaService().loadAssets(selectedAlbum!).then((value) {
                setState(() {
                  assetList = value;
                });
              });
            },
            items: albumList.map<DropdownMenuItem<AssetPathEntity>>(
                (AssetPathEntity album) {
              return DropdownMenuItem<AssetPathEntity>(
                value: album,
                child: FutureBuilder<int>(
                  future: album.assetCountAsync,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Return a loading indicator while awaiting the future
                      return const CircularProgressIndicator();
                    } else {
                      // Display the album name along with its asset count
                      return Text("${album.name} (${snapshot.data})");
                    }
                  },
                ),
              );
            }).toList(),
          ),
          actions: [
            if (selectedAssetList.isNotEmpty)
              IconButton(
                onPressed: _deleteSelectedAssets,
                icon: const Icon(Icons.delete),
              ),
          ],
        ),
        body: assetList.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: assetList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  AssetEntity assetEntity = assetList[index];
                  return GridTile(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PicturePage(assetEntity: assetEntity),
                          ),
                        );
                      },
                      child: assetWidget(assetEntity),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget assetWidget(AssetEntity assetEntity) => Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(
                  selectedAssetList.contains(assetEntity) == true ? 15 : 0),
              child: Image(
                image: AssetEntityImageProvider(
                  assetEntity,
                  isOriginal: false,
                  thumbnailSize: const ThumbnailSize.square(250),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  selectAsset(assetEntity: assetEntity, context: context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedAssetList.contains(assetEntity) == true
                          ? Colors.blue
                          : Colors.black12,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "${selectedAssetList.indexOf(assetEntity) + 1}",
                        style: TextStyle(
                          color: selectedAssetList.contains(assetEntity) == true
                              ? Colors.white
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  void selectAsset(
      {required AssetEntity assetEntity, required BuildContext context}) {
    if (selectedAssetList.contains(assetEntity)) {
      setState(() {
        selectedAssetList.remove(assetEntity);
      });
    } else if (selectedAssetList.length < widget.maxCount) {
      setState(() {
        selectedAssetList.add(assetEntity);
      });
    } else {
      // Maximum number of selections reached, show SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum number of selections reached'),
          duration:
              Duration(seconds: 2), // Duration for which SnackBar is displayed
        ),
      );
    }
  }
}
