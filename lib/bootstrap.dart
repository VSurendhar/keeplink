import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/core/di/injection.dart';
import 'package:mindful_links/features/logger/logger.dart';

Future<void> bootstrap() async {
  FlutterError.onError = (details) {
    logError(details.exceptionAsString(), details, stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logError(error.toString(), error, stackTrace: stack);
    return true;
  };

  await configureDependencies();
  seeDbWithDefaults();
}

void seeDbWithDefaults() async {
  await GetIt.instance.get<UrlStore>().seedDefaultFolderIfNotExist();
  await GetIt.instance.get<UrlStore>().seedDefaultTagsIfNotExist();
}
