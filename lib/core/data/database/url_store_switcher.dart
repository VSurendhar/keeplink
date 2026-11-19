import 'package:get_it/get_it.dart';
import 'package:keep_links/core/data/database/url_store.dart';

class UrlStoreSwitcher {
  static bool _isMock = false;

  static bool get isMock {
    if (!GetIt.instance.isRegistered<UrlStore>()) {
      return _isMock;
    }
    return GetIt.instance.get<UrlStore>() is MockUrlStore;
  }

  static void useMock() {
    _isMock = true;
    _replaceStore(MockUrlStore.new);
  }

  static void useReal() {
    _isMock = false;
    _replaceStore(DatabaseUrlStore.new);
  }

  static void toggle() {
    if (isMock) {
      useReal();
    } else {
      useMock();
    }
  }

  static void _replaceStore(UrlStore Function() storeFactory) {
    if (GetIt.instance.isRegistered<UrlStore>()) {
      GetIt.instance.unregister<UrlStore>();
    }
    GetIt.instance.registerLazySingleton<UrlStore>(storeFactory);
  }
}
