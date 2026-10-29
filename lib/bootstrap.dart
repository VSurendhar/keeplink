import 'package:flutter/foundation.dart';
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
}
