import 'package:photo_manager/photo_manager.dart';

class MediaService {
  Future loadAlbums(RequestType requestType) async {
    await PhotoManager.requestPermissionExtend();
    List<AssetPathEntity> albumList = [];

    albumList = await PhotoManager.getAssetPathList(
      type: requestType,
    );

    return albumList;
  }

  Future loadAssets(AssetPathEntity selectedAlbum) async {
    List<AssetEntity> assetList = await selectedAlbum.getAssetListRange(
      start: 0,
      end: await selectedAlbum.assetCountAsync,
    );
    return assetList;
  }
}
