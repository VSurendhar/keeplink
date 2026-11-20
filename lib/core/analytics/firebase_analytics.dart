import 'package:keep_links/core/analytics/analytics.dart';

class FirebaseAnalytics extends Analytics {
  @override
  void flush() {}

  @override
  Future<void> init() async {}

  @override
  void setSuperProperties(Map<String, String> properties) {}

  @override
  Future<void> trackEvent({
    required String eventName,
    Map<String, String> properties = const {},
  }) async {}
}
