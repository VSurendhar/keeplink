import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:keep_links/core/utils/constants.dart';
import 'package:keep_links/features/theme/theme.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Picks, crops and stores links' preview images.
///
/// Images are kept in `<app documents>/keep_links/`, which the OS doesn't
/// clear, and are identified by file name only; build the full path with
/// [filePathFor].
///
/// Errors are not caught here: callers in the business layer handle them.
@lazySingleton
class PreviewImageStorage {
  static const folderName = 'keep_links';

  final _picker = ImagePicker();
  final _cropper = ImageCropper();
  final _uuid = const Uuid();

  Future<Directory>? _directoryFuture;
  String? _directoryPath;

  /// Lets the user pick an image from [source] and crop it to
  /// [kPreviewImageAspectRatio] (locked).
  ///
  /// Returns the cropped file, still in a temporary location, or `null` if
  /// the user cancelled the picker or the cropper. Store it with [store].
  Future<CroppedFile?> pickAndCrop(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return null;

    return _cropper.cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(
        ratioX: kPreviewImageAspectRatio,
        ratioY: 1,
      ),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: KeepLinksTheme.secondaryLight,
          toolbarWidgetColor: KeepLinksTheme.textPrimary,
          statusBarLight: true,
          activeControlsWidgetColor: KeepLinksTheme.primaryDark,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );
  }

  /// Copies [croppedFile] into the preview image folder under a new random
  /// name and returns that file name (e.g. `3f2b…e91a.jpg`).
  Future<String> store(CroppedFile croppedFile) async {
    final directory = await _directory();
    final fileName = '${_uuid.v4()}${p.extension(croppedFile.path)}';
    await File(croppedFile.path).copy(p.join(directory.path, fileName));
    return fileName;
  }

  /// Deletes the stored image [fileName]. Does nothing if it doesn't exist.
  Future<void> delete(String fileName) async {
    final directory = await _directory();
    final file = File(p.join(directory.path, fileName));
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Full path of the stored image [fileName], for display.
  ///
  /// Returns `null` until the folder has been resolved, which [store] always
  /// does, so a name returned by [store] always has a path.
  String? filePathFor(String fileName) {
    final directoryPath = _directoryPath;
    if (directoryPath == null) return null;
    return p.join(directoryPath, fileName);
  }

  Future<Directory> _directory() => _directoryFuture ??= _createDirectory();

  Future<Directory> _createDirectory() async {
    try {
      final documents = await getApplicationDocumentsDirectory();
      final directory = await Directory(
        p.join(documents.path, folderName),
      ).create(recursive: true);
      _directoryPath = directory.path;
      return directory;
    } catch (_) {
      // Reset so the next call can retry.
      _directoryFuture = null;
      rethrow;
    }
  }
}
