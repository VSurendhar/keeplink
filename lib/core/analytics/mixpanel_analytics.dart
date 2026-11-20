import 'package:keep_links/core/analytics/analytics.dart';
import 'package:keep_links/core/utils/build_config.dart';
import 'package:keep_links/features/logger/logger.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixPanelAnalytics extends Analytics {
  /// `null` until [init] succeeds; until then every call only logs an error,
  /// so a failed or skipped [init] leaves analytics off.
  Mixpanel? _mixpanel;

  /// Throws a [StateError] when `MIXPANEL_TOKEN` was not provided at build time.
  @override
  Future<void> init() async {
    if (BuildConfig.mixpanelToken.isEmpty) {
      throw StateError(
        'MIXPANEL_TOKEN is not set. Run with --dart-define-from-file=secrets.json',
      );
    }
    _mixpanel = await Mixpanel.init(
      BuildConfig.mixpanelToken,
      trackAutomaticEvents: false,
    );
  }

  @override
  void flush() {
    _requireMixpanel('flush events')?.flush();
  }

  @override
  void setSuperProperties(Map<String, String> properties) {
    _requireMixpanel(
      'set super properties',
    )?.registerSuperPropertiesOnce(properties);
  }

  @override
  Future<void> trackEvent({
    required String eventName,
    Map<String, String> properties = const {},
  }) async {
    await _requireMixpanel(
      'track "$eventName"',
    )?.track(eventName, properties: properties);
  }

  /// Returns [_mixpanel], or logs that [operation] was skipped when it is
  /// `null` (no toast).
  Mixpanel? _requireMixpanel(String operation) {
    final mixpanel = _mixpanel;
    if (mixpanel == null) {
      logError('Mixpanel is null, so could not $operation', null);
    }
    return mixpanel;
  }
}
