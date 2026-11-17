class DuplicateTitleException implements Exception {
  const DuplicateTitleException(this.title);

  final String title;

  @override
  String toString() =>
      'DuplicateTitleException: Title "$title" already exists.';
}
