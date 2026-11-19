import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:keep_links/core/data/database/url_store.dart';
import 'package:keep_links/features/folder/bloc/folder_bloc.dart';
import 'package:keep_links/features/folder/bloc/folder_event.dart';

/// Lists the folders, with each folder's URL count and first URL.
class FolderPage extends StatelessWidget {
  const FolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FolderBloc(urlStoreProvider: GetIt.instance.get<UrlStore>)
            ..add(const OnInitEvent()),
      child: const FolderView(),
    );
  }
}

class FolderView extends StatelessWidget {
  const FolderView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Need to Create the UI for Success , Error , Loading....
    return Placeholder();
  }
}
