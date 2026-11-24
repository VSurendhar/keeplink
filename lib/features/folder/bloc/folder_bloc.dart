import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:keep_links/core/data/database/entity/folder.dart';
import 'package:keep_links/core/data/database/entity/url.dart';
import 'package:keep_links/core/data/database/url_store.dart';
import 'package:keep_links/features/folder/bloc/folder_event.dart';
import 'package:keep_links/features/folder/bloc/folder_state.dart';
import 'package:keep_links/features/logger/logger.dart';

/// The folders and URLs read from the same store.
typedef FoldersAndUrls = ({List<Folder> folders, List<Url> urls});

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  FolderBloc({
    required UrlStore Function() urlStoreProvider,
    required Stream<void> storeChanges,
  }) : _urlStoreProvider = urlStoreProvider,
       _storeChanges = storeChanges,
       super(const FolderLoadingState()) {
    on<OnInitEvent>(_onInit);
    on<OnRefreshClicked>(_onRefreshClicked);
    on<OnFolderItemClicked>(_onFolderItemClicked);
    on<OnCreateFolderClicked>(_onCreateFolderClicked);
    on<OnActionHandled>(_onActionHandled);
  }

  final UrlStore Function() _urlStoreProvider;

  /// Emits when the store is replaced (mock/real switch in Developer Options).
  final Stream<void> _storeChanges;

  /// Emits when the user asks to load the folders again.
  final StreamController<void> _refreshController =
      StreamController<void>.broadcast();

  @override
  Future<void> close() async {
    await super.close();
    await _refreshController.close();
  }

  /// Loads the folders and keeps them up to date with the folder and URL
  /// streams, until the BLoC closes.
  ///
  /// `emit.forEach` has no `onError`, so a stream error stops listening and is
  /// handled in the `catch`. Retrying starts listening again.
  Future<void> _onInit(OnInitEvent event, Emitter<FolderState> emit) async {
    emit(const FolderLoadingState());
    try {
      await emit.forEach(
        _watchFoldersAndUrls(),
        onData: (data) => _buildSuccessState(data.folders, data.urls),
      );
    } catch (e, st) {
      logError('Failed to load folders', e, stackTrace: st);
      emit(const FolderErrorState());
    }
  }

  /// Reads the folders and URLs again from the current store.
  ///
  /// After an error nothing is listening anymore (see [_onInit]), so it starts
  /// listening again instead.
  void _onRefreshClicked(OnRefreshClicked event, Emitter<FolderState> emit) {
    final hasFailed = state is FolderErrorState;
    emit(const FolderLoadingState());
    if (hasFailed) {
      add(const OnInitEvent());
    } else {
      _refreshController.add(null);
    }
  }

  /// Emits the current store's folders and URLs. Listens to the store again on
  /// refresh, and to the new one whenever it is replaced (this BLoC outlives
  /// the switch, IndexedStack).
  Stream<FoldersAndUrls> _watchFoldersAndUrls() {
    return Stream.multi((controller) {
      StreamSubscription<FoldersAndUrls>? dataSubscription;

      void listenToCurrentStore() {
        dataSubscription?.cancel();
        try {
          final urlStore = _urlStoreProvider();
          dataSubscription = _combineLatest(
            urlStore.findAllFolders(),
            urlStore.findAllUrl(),
          ).listen(controller.add, onError: controller.addError);
        } catch (e, st) {
          controller.addError(e, st);
        }
      }

      final changesSubscription = _storeChanges.listen(
        (_) => listenToCurrentStore(),
        onError: controller.addError,
      );
      final refreshSubscription = _refreshController.stream.listen(
        (_) => listenToCurrentStore(),
      );
      controller.onCancel = () async {
        await refreshSubscription.cancel();
        await changesSubscription.cancel();
        await dataSubscription?.cancel();
      };
      listenToCurrentStore();
    });
  }

  /// Emits the latest folders and URLs together whenever either stream emits,
  /// once both have emitted.
  Stream<FoldersAndUrls> _combineLatest(
    Stream<List<Folder>> folderStream,
    Stream<List<Url>> urlStream,
  ) {
    return Stream.multi((controller) {
      List<Folder>? latestFolders;
      List<Url>? latestUrls;

      void addLatest() {
        final folders = latestFolders;
        final urls = latestUrls;
        if (folders != null && urls != null) {
          controller.add((folders: folders, urls: urls));
        }
      }

      final folderSubscription = folderStream.listen((folders) {
        latestFolders = folders;
        addLatest();
      }, onError: controller.addError);
      final urlSubscription = urlStream.listen((urls) {
        latestUrls = urls;
        addLatest();
      }, onError: controller.addError);

      controller.onCancel = () =>
          Future.wait([folderSubscription.cancel(), urlSubscription.cancel()]);
    });
  }

  /// The success state for [folders] and [urls], keeping the other fields of
  /// the current one.
  FolderSuccessState _buildSuccessState(List<Folder> folders, List<Url> urls) {
    final current = state;
    final success = current is FolderSuccessState
        ? current
        : const FolderSuccessState();
    return success.copyWith(
      folderItemsList: _buildFolderItems(folders, urls),
      totalAvailableUrl: urls.length,
    );
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

  /// Builds one [FolderItem] per folder, with its URL count and first URL
  /// taken from [urls].
  List<FolderItem> _buildFolderItems(List<Folder> folders, List<Url> urls) {
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
}
