class UrlNotFoundException implements Exception {
  const UrlNotFoundException(this.urlId);

  final int urlId;

  @override
  String toString() => 'URL does not exist';
}
