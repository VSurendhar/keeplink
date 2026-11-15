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
import 'package:mindful_links/utils/Utils.dart';

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
    showToast(details.exceptionAsString());
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logError(error.toString(), error, stackTrace: stack);
    showToast(error.toString());
    return true;
  };

  await configureDependencies();
  await seedDbWithDefaults();
}

void showToast(String message) {
  Utils.showToast(message);
}

/// Seeding failures are logged, not rethrown, so `runApp` still runs.
Future<void> seedDbWithDefaults() async {
  try {
    final urlStore = GetIt.instance.get<UrlStore>();
    await urlStore.seedDefaultFolderIfNotExist();
    await urlStore.seedDefaultTagsIfNotExist();
  } catch (e, st) {
    logError('Failed to seed default folders/tags', e, stackTrace: st);
  }
}
