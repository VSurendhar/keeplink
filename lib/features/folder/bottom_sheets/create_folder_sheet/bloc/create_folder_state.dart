import 'package:equatable/equatable.dart';
import 'package:keep_links/features/folder/bottom_sheets/create_folder_sheet/bloc/create_folder_action.dart';

export 'package:keep_links/features/folder/bottom_sheets/create_folder_sheet/bloc/create_folder_action.dart';

final class CreateFolderState extends Equatable {
  const CreateFolderState({
    this.name = '',
    this.isCreating = false,
    this.action,
  });

  /// The folder name as typed.
  final String name;

  /// Whether the folder is being saved.
  final bool isCreating;

  /// One-shot UI action for the view to perform, or `null` if there is none.
  final CreateFolderAction? action;

  bool get isCreateEnabled => name.trim().isNotEmpty && !isCreating;

  CreateFolderState copyWith({
    String? name,
    bool? isCreating,
    CreateFolderAction? action,
    bool clearAction = false,
  }) {
    return CreateFolderState(
      name: name ?? this.name,
      isCreating: isCreating ?? this.isCreating,
      action: clearAction ? null : (action ?? this.action),
    );
  }

  @override
  List<Object?> get props => [name, isCreating, action];

  @override
  String toString() {
    return 'CreateFolderState{name: $name, isCreating: $isCreating, action: $action}';
  }
}
