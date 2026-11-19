import 'package:bloc/bloc.dart';
import 'package:mindful_links/core/data/database/entity/url.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/features/folder/bloc/folder_event.dart';
import 'package:mindful_links/features/folder/bloc/folder_state.dart';
import 'package:mindful_links/features/logger/logger.dart';

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  FolderBloc({required UrlStore Function() urlStoreProvider})
    : _urlStoreProvider = urlStoreProvider,
      super(const FolderLoadingState()) {
    on<OnInitEvent>(_onInit);
    on<OnFolderItemClicked>(_onFolderItemClicked);
    on<OnCreateFolderClicked>(_onCreateFolderClicked);
    on<OnActionHandled>(_onActionHandled);
  }

  final UrlStore Function() _urlStoreProvider;

  /// Loads the folders, with each folder's URL count and first URL.
  Future<void> _onInit(OnInitEvent event, Emitter<FolderState> emit) async {
    emit(const FolderLoadingState());
    try {
      final folderItems = await _loadFolderItems();
      emit(FolderSuccessState(folderItemsList: folderItems));
    } catch (e, st) {
      logError('Failed to load folders', e, stackTrace: st);
      emit(const FolderErrorState());
    }
  }

  void _onFolderItemClicked(
    OnFolderItemClicked event,
    Emitter<FolderState> emit,
  ) {}

  void _onCreateFolderClicked(
    OnCreateFolderClicked event,
    Emitter<FolderState> emit,
  ) {}

  /// Clears the action the view has just performed. Actions only exist on
  /// [FolderSuccessState].
  void _onActionHandled(OnActionHandled event, Emitter<FolderState> emit) {
    final current = state;
    if (current is FolderSuccessState) {
      emit(current.copyWith(clearAction: true));
    }
  }

  /// Builds one [FolderItem] per folder, with its URL count and first URL.
  Future<List<FolderItem>> _loadFolderItems() async {
    final urlStore = _urlStoreProvider();
    final folders = await urlStore.findAllFolders().first;
    final urls = await urlStore.findAllUrl().first;

    final urlCountByFolderId = UrlStore.countById(
      urls.map((url) => url.folderId),
    );
    final firstUrlByFolderId = _findFirstUrlPerFolder(urls);

    return folders.map((folder) {
      final id = folder.id;
      return FolderItem(
        folder: folder,
        totalUrl: id == null ? 0 : (urlCountByFolderId[id] ?? 0),
        firstUrl: id == null ? null : firstUrlByFolderId[id]?.url,
      );
    }).toList();
  }

  /// The earliest saved URL (lowest `createdAt`) in each folder, keyed by
  /// folder id. Folders with no URLs are not in the map.
  Map<int, Url> _findFirstUrlPerFolder(List<Url> urls) {
    final firstUrlByFolderId = <int, Url>{};
    for (final url in urls) {
      final current = firstUrlByFolderId[url.folderId];
      if (current == null || url.createdAt < current.createdAt) {
        firstUrlByFolderId[url.folderId] = url;
      }
    }
    return firstUrlByFolderId;
  }

  void onRefresh() {}
}
