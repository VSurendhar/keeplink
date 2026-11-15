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
    required this.folder,
    required this.tags,
    this.action,
  });

  final String urlName;
  final String url;
  final String imageUrl;
  final Folder folder;
  final List<Tag> tags;
  final AddNewLinkAction? action;

  factory AddNewLinkState.initial() {
    return AddNewLinkState(
      urlName: '',
      url: '',
      folder: AppDefaults.defaultFolders.first,
      tags: [],
    );
  }

  AddNewLinkState copyWith({
    String? urlName,
    String? url,
    String? imageUrl,
    Folder? folder,
    List<Tag>? tags,
    AddNewLinkAction? action,
    bool clearAction = false,
  }) {
    return AddNewLinkState(
      urlName: urlName ?? this.urlName,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      folder: folder ?? this.folder,
      tags: tags ?? this.tags,
      action: clearAction ? null : (action ?? this.action),
    );
  }

  bool get isSaveEnabled =>
      urlName.trim().isNotEmpty &&
      url.trim().isNotEmpty &&
      folder.folderName.trim().isNotEmpty;

  @override
  List<Object?> get props => [urlName, url, imageUrl, folder, tags, action];

  @override
  String toString() {
    return 'AddNewLinkState{urlName: $urlName, url: $url, imageUrl: $imageUrl, folder: $folder, tags: $tags, action: $action}';
  }
}
