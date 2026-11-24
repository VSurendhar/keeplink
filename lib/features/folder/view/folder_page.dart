import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:keep_links/core/data/database/url_store.dart';
import 'package:keep_links/features/folder/bloc/folder_bloc.dart';
import 'package:keep_links/features/folder/bloc/folder_event.dart';
import 'package:keep_links/features/folder/bloc/folder_state.dart';
import 'package:keep_links/features/folder/view/widgets/folder_card.dart';
import 'package:keep_links/features/home/constants/constants.dart';
import 'package:keep_links/features/theme/colors.dart';
import 'package:keep_links/features/theme/theme.dart';

/// Lists the folders, with each folder's URL count and first URL.
class FolderPage extends StatelessWidget {
  const FolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FolderBloc(
        urlStoreProvider: GetIt.instance.get<UrlStore>,
        storeChanges: UrlStoreSwitcher.storeChanges,
      )..add(const OnInitEvent()),
      child: const FolderView(),
    );
  }
}

class FolderView extends StatelessWidget {
  const FolderView({super.key});

  /// Size of the floating button. The list leaves room for it, so its last
  /// item can be scrolled clear of the button.
  static const double _fabSize = 56;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KeepLinksTheme.secondaryLight,
      appBar: _buildAppBar(context),
      floatingActionButton: _buildFab(),
      body: SafeArea(
        top: false,
        child: BlocBuilder<FolderBloc, FolderState>(
          builder: (context, state) {
            return switch (state) {
              FolderLoadingState() => Center(
                child: CircularProgressIndicator(
                  color: KeepLinksColors.appBarTitleColor,
                ),
              ),
              FolderErrorState() => _buildError(context),
              FolderSuccessState() => _buildFolders(context, state),
            };
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: KeepLinksTheme.secondaryLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Text(
        'Keep Links',
        style: TextStyle(
          color: KeepLinksColors.appBarTitleColor,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        _buildAppBarIcon(
          tooltip: 'Trash',
          icon: Icons.delete_outline_rounded,
          onPressed: () {
            // TODO: Open the trash screen once it exists.
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildAppBarIcon(
            tooltip: 'Refresh',
            icon: Icons.refresh_rounded,
            onPressed: () {
              context.read<FolderBloc>().add(const OnRefreshClicked());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarIcon({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 24, color: KeepLinksColors.appBarTitleColor),
      onPressed: onPressed,
    );
  }

  Widget _buildFab() {
    return Padding(
      padding: const EdgeInsets.only(bottom: paddingForBottomNavBar),
      child: SizedBox.square(
        dimension: _fabSize,
        child: FloatingActionButton(
          backgroundColor: KeepLinksColors.appBarTitleColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () {
            // TODO: Add the FAB functionality.
          },
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Error While Loading Folders',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: KeepLinksColors.headerSubTitleColor,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: KeepLinksColors.appBarTitleColor,
            ),
            onPressed: () {
              context.read<FolderBloc>().add(const OnInitEvent());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFolders(BuildContext context, FolderSuccessState state) {
    final items = state.folderItemsList;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: _buildHeader(
              totalFolders: items.length,
              totalUrls: state.totalAvailableUrl,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            paddingForBottomNavBar + _fabSize + kFloatingActionButtonMargin,
          ),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: FolderCard.heightOf(context),
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return FolderCard(
                item: item,
                onTap: () {
                  final folderId = item.folder.id;
                  if (folderId == null) return;
                  context.read<FolderBloc>().add(
                    OnFolderItemClicked(folderId: folderId),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// A [Wrap], so the totals move below the title when they don't fit next
  /// to it.
  Widget _buildHeader({required int totalFolders, required int totalUrls}) {
    final folders = totalFolders == 1 ? 'Folder' : 'Folders';
    final links = totalUrls == 1 ? 'Link' : 'Links';

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        Text(
          'Your Folders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: KeepLinksColors.headerTitleColor,
          ),
        ),
        Text(
          '$totalFolders $folders • $totalUrls $links',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF857B74),
          ),
        ),
      ],
    );
  }
}
