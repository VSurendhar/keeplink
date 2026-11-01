import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mindful_links/app/app.dart';
import 'package:mindful_links/app/app_bloc_observer.dart';
import 'package:mindful_links/core/build_config.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/core/di/injection.dart';
import 'package:mindful_links/features/logger/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    BuildConfig.isDevelopmentBuild = true;
  } else {
    BuildConfig.isDevelopmentBuild = false;
  }

  if (BuildConfig.isDeveloperOrDebug) {
    Bloc.observer = const AppBlocObserver();
  }

  await bootstrap();

  runApp(const App());
}

Future<void> bootstrap() async {
  FlutterError.onError = (details) {
    logError(details.exceptionAsString(), details, stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logError(error.toString(), error, stackTrace: stack);
    return true;
  };

  await configureDependencies();
  await seedDbWithDefaults();
}

Future<void> seedDbWithDefaults() async {
  await GetIt.instance.get<UrlStore>().seedDefaultFolderIfNotExist();
  await GetIt.instance.get<UrlStore>().seedDefaultTagsIfNotExist();
}
