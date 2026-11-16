class TagNotFoundException implements Exception {
  const TagNotFoundException(this.tagId);

  final int tagId;

  @override
  String toString() => 'Tag does not exist';
}
