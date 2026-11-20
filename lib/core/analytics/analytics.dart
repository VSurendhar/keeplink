abstract class Analytics {
  Future<void> init();

  Future<void> trackEvent({
    required String eventName,
    Map<String, String> properties,
  });

  void setSuperProperties(Map<String, String> properties);

  void flush();
}
