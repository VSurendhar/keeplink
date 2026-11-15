import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/common/widgets/save_button.dart';
import 'package:mindful_links/features/add_new_link/bloc/add_new_link_bloc.dart';
import 'package:mindful_links/features/add_new_link/bloc/add_new_link_event.dart';
import 'package:mindful_links/features/add_new_link/bloc/add_new_link_state.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/folder_selection_sheet/view/show_folder_selection_sheet.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/tag_selection_sheet/view/show_tag_selection_sheet.dart';
import 'package:mindful_links/features/add_new_link/view/widgets/link_preview_card_widget.dart';
import 'package:mindful_links/features/add_new_link/view/widgets/tag_selection_widget.dart';
import 'package:mindful_links/features/home/constants/constants.dart';
import 'package:mindful_links/features/theme/colors.dart';
import 'package:mindful_links/features/theme/theme.dart';

class AddNewLinkPage extends StatelessWidget {
  const AddNewLinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddNewLinkBloc(),
      child: const AddNewLinkView(),
    );
  }
}

class AddNewLinkView extends StatelessWidget {
  const AddNewLinkView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddNewLinkBloc, AddNewLinkState>(
      listenWhen: (previous, current) =>
          current.action != null && previous.action != current.action,
      listener: (context, state) {
        final action = state.action;
        if (action == null) return;

        if (action is ShowFolderSelectionSheetAction) {
          _showFolderSelectionSheet(context, selectedFolder: state.folder);
        } else if (action is ShowTagSelectionSheetAction) {
          _showTagSelectionSheet(context, selectedTags: state.tags);
        }

        context.read<AddNewLinkBloc>().add(const OnActionHandled());
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: MindfulLinksTheme.secondaryLight,
          appBar: AppBar(
            backgroundColor: MindfulLinksTheme.secondaryLight,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: MindfulLinkColors.headerTitleColor,
                size: 24,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: Text(
              'Add Link',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: MindfulLinkColors.headerTitleColor,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SaveButton(
                  isEnabled: state.isSaveEnabled,
                  onPressed: () {
                    context.read<AddNewLinkBloc>().add(const OnSaveClicked());
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameInputCard(context),
                  const SizedBox(height: 16),
                  _buildUrlInputCard(context),
                  const SizedBox(height: 16),
                  LinkPreviewCardWidget(
                    previewImageUrl: state.imageUrl.isNotEmpty
                        ? state.imageUrl
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildSaveToFolderCard(
                    context,
                    folderName: state.folder.folderName,
                  ),
                  const SizedBox(height: 16),
                  _buildTagSection(context, tags: state.tags),
                  const SizedBox(height: paddingForBottomNavBar),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF9E8E85),
      ),
    );
  }

  Widget _buildNameInputCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D2926).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: context.read<AddNewLinkBloc>().nameController,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: MindfulLinkColors.headerTitleColor,
        ),
        onChanged: (value) {
          context.read<AddNewLinkBloc>().add(OnNameChanged(value));
        },
        decoration: const InputDecoration(
          hintText: 'Enter the Name',
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF857B74),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildUrlInputCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D2926).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.link_rounded, color: Color(0xFF52443D), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: context.read<AddNewLinkBloc>().urlController,
              focusNode: context.read<AddNewLinkBloc>().urlFocusNode,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1E1B18),
              ),
              onChanged: (value) {
                context.read<AddNewLinkBloc>().add(OnUrlChanged(value));
              },
              decoration: const InputDecoration(
                hintText: 'Enter link URL',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF857B74),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: context.read<AddNewLinkBloc>().urlController,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      context.read<AddNewLinkBloc>().urlController.clear();
                      context.read<AddNewLinkBloc>().urlFocusNode.unfocus();
                      context.read<AddNewLinkBloc>().add(
                        const OnUrlChanged(''),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDE5DF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close_rounded,
                        size: 12,
                        color: Color(0xFF52443D),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveToFolderCard(
    BuildContext context, {
    required String folderName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Save To'),
        const SizedBox(height: 12),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              context.read<AddNewLinkBloc>().add(
                const OnShowFolderSheetRequested(),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D2926).withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF0E8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.folder_outlined,
                      color: MindfulLinkColors.headerSubTitleColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      folderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Icon(
                    Symbols.unfold_more,
                    color: Color(0xFFD7C2B9),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSection(BuildContext context, {required List<Tag> tags}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tags'),
        const SizedBox(height: 12),
        TagSelectionWidget(
          tags: tags,
          onRemoveTag: (tag) {
            context.read<AddNewLinkBloc>().add(OnTagRemoved(tag));
          },
          onAddTagTap: () {
            context.read<AddNewLinkBloc>().add(const OnShowTagSheetRequested());
          },
        ),
      ],
    );
  }

  Future<void> _showFolderSelectionSheet(
    BuildContext context, {
    required Folder selectedFolder,
  }) async {
    final folder = await showFolderSelectionSheet(
      context,
      selectedFolder: selectedFolder,
    );
    if (folder != null && context.mounted) {
      context.read<AddNewLinkBloc>().add(OnFolderSelected(folder: folder));
    }
  }

  Future<void> _showTagSelectionSheet(
    BuildContext context, {
    required List<Tag> selectedTags,
  }) async {
    final tags = await showTagSelectionSheet(
      context,
      selectedTags: selectedTags,
    );
    if (tags != null && context.mounted) {
      context.read<AddNewLinkBloc>().add(OnTagsSelected(tags));
    }
  }
}
