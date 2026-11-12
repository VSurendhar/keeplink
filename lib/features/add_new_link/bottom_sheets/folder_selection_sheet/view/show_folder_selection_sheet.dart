import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/folder_selection_sheet/bloc/folder_selection_bloc.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/folder_selection_sheet/bloc/folder_selection_event.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/folder_selection_sheet/view/widget/folder_selection_sheet_widget.dart';

Future<Folder?> showFolderSelectionSheet(
  BuildContext context, {
  required Folder selectedFolder,
}) {
  return showModalBottomSheet<Folder>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => LayoutBuilder(
      builder: (_, constraints) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.75),
        child: BlocProvider(
          create: (_) => FolderSelectionBloc(
            urlStore: GetIt.instance.get<UrlStore>(),
            initialSelectedFolder: selectedFolder,
          )..add(const OnInitEvent()),
          child: AnimatedSize(
            duration: Duration(milliseconds: 250),
            child: const FolderSelectionSheetWidget(),
          ),
        ),
      ),
    ),
  );
}
