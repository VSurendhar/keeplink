import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final _getIt = GetIt.instance;

bool _isConfigured = false;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() {
  if (_isConfigured) return;
  _getIt.init();
  _isConfigured = true;
}
