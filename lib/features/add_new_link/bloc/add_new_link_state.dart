import 'package:equatable/equatable.dart';
import 'package:mindful_links/core/app_defaults.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/features/add_new_link/bloc/add_new_link_action.dart';

export 'package:mindful_links/features/add_new_link/bloc/add_new_link_action.dart';

final class AddNewLinkState extends Equatable {
  const AddNewLinkState({
    required this.urlName,
    required this.url,
    this.imageUrl = '',
    required this.selectedFolder,
    required this.selectedTags,
    this.isSaving = false,
    this.previewImageName,
    this.isSavingPreviewImage = false,
    this.action,
  });

  final String urlName;
  final String url;
  final String imageUrl;
  final Folder selectedFolder;
  final List<Tag> selectedTags;

  /// Whether a save is in progress; drives the Save button's loading state.
  final bool isSaving;

  /// File name of the stored preview image, or `null` if none was picked.
  final String? previewImageName;

  /// Whether a picked image is being copied into storage; drives the preview
  /// box's spinner and keeps the Save button disabled.
  final bool isSavingPreviewImage;
  final AddNewLinkAction? action;

  factory AddNewLinkState.initial() {
    return AddNewLinkState(
      urlName: '',
      url: '',
      selectedFolder: AppDefaults.defaultFolders.first,
      selectedTags: [],
    );
  }

  AddNewLinkState copyWith({
    String? urlName,
    String? url,
    String? imageUrl,
    Folder? selectedFolder,
    List<Tag>? selectedTags,
    bool? isSaving,
    String? previewImageName,
    bool? isSavingPreviewImage,
    AddNewLinkAction? action,
    bool clearAction = false,
  }) {
    return AddNewLinkState(
      urlName: urlName ?? this.urlName,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      selectedFolder: selectedFolder ?? this.selectedFolder,
      selectedTags: selectedTags ?? this.selectedTags,
      isSaving: isSaving ?? this.isSaving,
      previewImageName: previewImageName ?? this.previewImageName,
      isSavingPreviewImage: isSavingPreviewImage ?? this.isSavingPreviewImage,
      action: clearAction ? null : (action ?? this.action),
    );
  }

  bool get isSaveEnabled =>
      !isSavingPreviewImage &&
      urlName.trim().isNotEmpty &&
      url.trim().isNotEmpty &&
      selectedFolder.folderName.trim().isNotEmpty;

  @override
  List<Object?> get props => [
    urlName,
    url,
    imageUrl,
    selectedFolder,
    selectedTags,
    isSaving,
    previewImageName,
    isSavingPreviewImage,
    action,
  ];

  @override
  String toString() {
    return 'AddNewLinkState{urlName: $urlName, url: $url, imageUrl: $imageUrl, selectedFolder: $selectedFolder, selectedTags: $selectedTags, isSaving: $isSaving, previewImageName: $previewImageName, isSavingPreviewImage: $isSavingPreviewImage, action: $action}';
  }
}
