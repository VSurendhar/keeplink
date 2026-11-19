import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:keep_links/core/data/database/entity/tag.dart';
import 'package:keep_links/core/data/database/url_store.dart';
import 'package:keep_links/features/add_new_link/bottom_sheets/tag_selection_sheet/bloc/tag_selection_bloc.dart';
import 'package:keep_links/features/add_new_link/bottom_sheets/tag_selection_sheet/bloc/tag_selection_event.dart';
import 'package:keep_links/features/add_new_link/bottom_sheets/tag_selection_sheet/view/widget/tag_selection_sheet_widget.dart';

Future<List<Tag>?> showTagSelectionSheet(
  BuildContext context, {
  required List<Tag> selectedTags,
}) {
  return showModalBottomSheet<List<Tag>>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => LayoutBuilder(
      builder: (_, constraints) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.75),
        child: BlocProvider(
          create: (_) => TagSelectionBloc(
            urlStore: GetIt.instance.get<UrlStore>(),
            initialSelectedTags: selectedTags,
          )..add(const OnTagInit()),
          child: PopScope(
            canPop: false,
            child: AnimatedSize(
              duration: Duration(milliseconds: 250),
              child: const TagSelectionSheetWidget(),
            ),
          ),
        ),
      ),
    ),
  );
}
