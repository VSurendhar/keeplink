import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:keep_links/core/data/database/url_store.dart';
import 'package:keep_links/features/folder/bottom_sheets/create_folder_sheet/bloc/create_folder_bloc.dart';
import 'package:keep_links/features/folder/bottom_sheets/create_folder_sheet/view/widget/create_folder_sheet_widget.dart';

/// Lets the user create a folder.
Future<void> showCreateFolderSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => CreateFolderBloc(urlStore: GetIt.instance.get<UrlStore>()),
      child: const CreateFolderSheetWidget(),
    ),
  );
}
