import 'package:injectable/injectable.dart';
import 'package:keep_links/core/analytics/analytics.dart';
import 'package:keep_links/core/analytics/firebase_analytics.dart';
import 'package:keep_links/core/analytics/mixpanel_analytics.dart';
import 'package:keep_links/features/logger/logger.dart';

/// App-wide analytics entry point. Resolve it from GetIt.
///
/// Every call goes to each client in [_analyticsList], each in its own
/// `try/catch`, so one failing client never stops the others.
@lazySingleton
class AppAnalytics {
  final List<Analytics> _analyticsList = [
    MixPanelAnalytics(),
    FirebaseAnalytics(),
  ];

  /// A client whose init fails just doesn't track.
  Future<void> init() async {
    for (final analytics in _analyticsList) {
      try {
        await analytics.init();
      } catch (e, st) {
        logError(
          'Failed to initialize ${analytics.runtimeType}',
          e,
          stackTrace: st,
          isShowToastInDebug: true,
        );
      }
    }
  }

  /// Sends queued events now instead of waiting for the next batch upload.
  void flush() {
    for (final analytics in _analyticsList) {
      try {
        analytics.flush();
      } catch (e, st) {
        logError('${analytics.runtimeType} failed to flush', e, stackTrace: st);
      }
    }
  }

  Future<void> trackEvent({
    required String eventName,
    Map<String, String> properties = const {},
  }) async {
    for (final analytics in _analyticsList) {
      try {
        await analytics.trackEvent(
          eventName: eventName,
          properties: properties,
        );
      } catch (e, st) {
        logError(
          '${analytics.runtimeType} failed to track "$eventName"',
          e,
          stackTrace: st,
        );
      }
    }
  }
}
