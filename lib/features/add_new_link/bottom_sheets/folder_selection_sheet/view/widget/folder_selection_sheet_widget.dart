import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/folder_selection_sheet/bloc/folder_selection_bloc.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/folder_selection_sheet/bloc/folder_selection_state.dart';
import 'package:mindful_links/features/theme/theme.dart';

class FolderSelectionSheetWidget extends StatelessWidget {
  const FolderSelectionSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FolderSelectionBloc, FolderSelectionState>(
      builder: (context, state) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDragHandle(),
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 4),
                _buildSubtitle(),
                const SizedBox(height: 16),
                _buildCreateNewFolderRow(),
                const SizedBox(height: 12),
                Flexible(
                  child: state.isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _buildFolderList(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE0D5CE),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Save to Folder',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E1B18),
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Choose a collection or create a fresh one.',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF857B74),
      ),
    );
  }

  Widget _buildCreateNewFolderRow() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0D5CE), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO "Navigate to Create Folder UI"
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: MindfulLinksTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.create_new_folder_outlined,
                    color: Color(0xFF7A4326),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '+ Create New Folder',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1B18),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Organize links into a bespoke space',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF857B74),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.add, color: Color(0xFF9E8E85), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFolderList(BuildContext context, FolderSelectionState state) {
    if (state.folders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No folders found',
            style: TextStyle(fontSize: 14, color: Color(0xFF9E8E85)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: state.folders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        return _buildFolderItem(
          context: context,
          item: state.folders[index],
          selectedFolder: state.selectedFolder,
        );
      },
    );
  }

  Widget _buildFolderItem({
    required BuildContext context,
    required FolderItem item,
    required Folder? selectedFolder,
  }) {
    final folder = item.folder;
    final isSelected =
        selectedFolder != null &&
        selectedFolder.folderName == folder.folderName &&
        selectedFolder.id == folder.id;

    return Material(
      color: isSelected ? const Color(0xFFFAF0E8) : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.pop(context, folder);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFE4CC)
                      : const Color(0xFFF5EDE8),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isSelected ? Icons.folder_rounded : Icons.folder_outlined,
                  size: 20,
                  color: isSelected
                      ? const Color(0xFF7A4326)
                      : const Color(0xFF9E8E85),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.folderName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: const Color(0xFF1E1B18),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.linkCount} links',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF857B74),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildSelectionIndicator(isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    if (isSelected) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: Color(0xFF7A4326),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
      );
    }
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFFF5EDE8),
        shape: BoxShape.circle,
      ),
    );
  }
}
