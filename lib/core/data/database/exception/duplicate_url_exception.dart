class DuplicateUrlException implements Exception {
  const DuplicateUrlException(this.url);

  final String url;

  @override
  String toString() => 'DuplicateUrlException: URL "$url" already exists.';
}
