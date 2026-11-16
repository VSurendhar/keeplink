import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/tag_selection_sheet/bloc/tag_selection_event.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/tag_selection_sheet/bloc/tag_selection_state.dart';
import 'package:mindful_links/features/logger/logger.dart';

class TagSelectionBloc extends Bloc<TagSelectionEvent, TagSelectionState> {
  TagSelectionBloc({
    required this.urlStore,
    List<Tag> initialSelectedTags = const [],
  }) : super(TagSelectionState.initial(initialSelectedTags)) {
    createTagController = TextEditingController();
    createTagFocusNode = FocusNode();

    on<OnTagInit>(_onInit);
    on<OnTagToggled>(_onTagToggled);
    on<OnTagRemove>(_onTagRemove);
    on<OnClearAllRequested>(_onClearAll);
    on<OnToggleCreateMode>(_onToggleCreateMode);
    on<OnSaveTagClicked>(_onSaveTagClicked);
    on<OnActionHandled>(_onActionHandled);
  }

  final UrlStore urlStore;
  late final TextEditingController createTagController;
  late final FocusNode createTagFocusNode;

  @override
  Future<void> close() {
    createTagController.dispose();
    createTagFocusNode.dispose();
    return super.close();
  }

  void _onToggleCreateMode(
    OnToggleCreateMode event,
    Emitter<TagSelectionState> emit,
  ) {
    final nextState = !state.isCreating;
    if (nextState) {
      createTagFocusNode.requestFocus();
    } else {
      createTagFocusNode.unfocus();
    }
    emit(state.copyWith(isCreating: nextState));
  }

  Future<void> _onSaveTagClicked(
    OnSaveTagClicked event,
    Emitter<TagSelectionState> emit,
  ) async {
    createTagFocusNode.unfocus();
    final name = createTagController.text.trim();
    if (name.isEmpty || name.length > 24) {
      emit(
        state.copyWith(
          action: const ShowToast(
            'Tag name must be between 1 and 24 characters',
          ),
        ),
      );
      return;
    }

    final alreadyExists = state.tags.any(
      (item) => item.tag.tagName.trim() == name,
    );
    if (alreadyExists) {
      emit(state.copyWith(action: ShowToast('Tag already exists')));
      return;
    }

    try {
      final id = await urlStore.insertTag(Tag(tagName: name));
      createTagController.clear();

      // Tags are multi-select: add the new tag to the selection, keep the sheet open.
      emit(
        state.copyWith(
          isCreating: false,
          selectedTags: [
            ...state.selectedTags,
            Tag(id: id, tagName: name),
          ],
        ),
      );
    } catch (e, st) {
      logError('Failed to create tag', e, stackTrace: st);
      emit(state.copyWith(action: const ShowToast('Error While Creating Tag')));
    }
  }

  void _onActionHandled(
    OnActionHandled event,
    Emitter<TagSelectionState> emit,
  ) {
    emit(state.copyWith(clearAction: true));
  }

  Future<void> _onInit(OnTagInit event, Emitter<TagSelectionState> emit) async {
    emit(state.copyWith(isLoading: true));

    var urlCountByTagId = const <int, int>{};
    try {
      urlCountByTagId = await urlStore.findUrlCountPerTag();
    } catch (e, st) {
      logError(
        'Failed to load tag link counts',
        e,
        stackTrace: st,
        isShowToastInDebug: true,
      );
    }

    await emit.forEach<List<Tag>>(
      urlStore.findAllTags(),
      onData: (tags) {
        final items = tags.map((tag) {
          final id = tag.id;
          final linkCount = id == null ? 0 : (urlCountByTagId[id] ?? 0);
          return TagItem(tag: tag, linkCount: linkCount);
        }).toList();

        // No matching like _matchSelectedFolder: selected tags always come from the database, so they already have an id.
        return state.copyWith(
          isLoading: false,
          tags: items,
          totalTagCount: items.length,
        );
      },
      onError: (e, st) {
        logError(
          'Failed to load tags',
          e,
          stackTrace: st,
          isShowToastInDebug: true,
        );
        return state.copyWith(isLoading: false);
      },
    );
  }

  void _onTagToggled(OnTagToggled event, Emitter<TagSelectionState> emit) {
    createTagFocusNode.unfocus();
    final selectedTags = List<Tag>.from(state.selectedTags);
    final exists = selectedTags.any(
      (t) => t.tagName == event.tag.tagName && t.id == event.tag.id,
    );
    if (exists) {
      selectedTags.removeWhere(
        (t) => t.tagName == event.tag.tagName && t.id == event.tag.id,
      );
    } else {
      selectedTags.add(event.tag);
    }
    emit(state.copyWith(selectedTags: selectedTags));
  }

  void _onTagRemove(OnTagRemove event, Emitter<TagSelectionState> emit) {
    createTagFocusNode.unfocus();
    final selectedTags = List<Tag>.from(state.selectedTags)
      ..removeWhere(
        (t) => t.tagName == event.tag.tagName && t.id == event.tag.id,
      );
    emit(state.copyWith(selectedTags: selectedTags));
  }

  void _onClearAll(OnClearAllRequested event, Emitter<TagSelectionState> emit) {
    createTagFocusNode.unfocus();
    emit(state.copyWith(selectedTags: const []));
  }
}

class TagItem extends Equatable {
  const TagItem({required this.tag, required this.linkCount});

  final Tag tag;
  final int linkCount;

  @override
  List<Object?> get props => [tag.id, tag.tagName, linkCount];
}
