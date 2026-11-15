import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:mindful_links/core/data/hive/hive_service.dart';
import 'package:mindful_links/features/logger/logger.dart';

import 'injection.config.dart';

final _getIt = GetIt.instance;

bool _isConfigured = false;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  if (_isConfigured) return;
  _isConfigured = true;
  _getIt.init();
  initLogger();
  try {
    await HiveService.init();
  } catch (e, st) {
    logError(
      'Failed to initialize Hive',
      e,
      stackTrace: st,
      isShowToastInDebug: true,
    );
  }
}
