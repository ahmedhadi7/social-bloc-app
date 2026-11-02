import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_bloc/features/storage/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage storage = FirebaseStorage.instance;

  // mobile platforms
  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, 'profile_images');
  }

  //web platforms
  @override
  Future<String?> uploadProfileImageWeb(
    Uint8List fileBytes,
    String fileName,
    String? fileExtension,
  ) {
    return _uploadFileBytes(
      fileBytes,
      fileName,
      'profile_images',
      fileExtension,
    );
  }

  /*
  POST IMAGES - to upload files to storage
  

  */
  @override
  Future<String?> uploadPostImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, 'post_images');
  }

  @override
  Future<String?> uploadPostImageWeb(
    Uint8List fileBytes,
    String fileName,
    String? fileExtension,
  ) {
    return _uploadFileBytes(fileBytes, fileName, 'post_images', fileExtension);
  }

  //mobile platforms (file)
  Future<String?> _uploadFile(
    String path,
    String fileName,
    String folder,
  ) async {
    try {
      //get file
      final file = File(path);

      //find place to store
      final storageRef = storage.ref().child('$folder/$fileName');
      //upload
      final uploadTask = storageRef.putFile(file);
      //
      final taskSnapshot = await uploadTask;
      //get image download url
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  //web platforms (bytes)
  Future<String?> _uploadFileBytes(
    Uint8List fileBytes,
    String fileName,
    String folder,
    String? fileExtension,
  ) async {
    try {
      final storageRef = storage.ref().child('$folder/$fileName');

      final metadata = SettableMetadata(
        contentType: _contentTypeForExtension(fileExtension),
      );

      final uploadTask = storageRef.putData(fileBytes, metadata);

      final taskSnapshot = await uploadTask;

      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      print('UPLOAD SUCCESS');
      print('URL: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      print('UPLOAD ERROR: $e');
      print(stackTrace);
      return null;
    }
  }

  String _contentTypeForExtension(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'jpe':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'svg':
        return 'image/svg+xml';
      case 'tif':
      case 'tiff':
        return 'image/tiff';
      case 'avif':
        return 'image/avif';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      default:
        return 'application/octet-stream';
    }
  }
}
