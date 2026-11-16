class FolderNotFoundException implements Exception {
  const FolderNotFoundException(this.folderId);

  final int folderId;

  @override
  String toString() => 'Folder does not exist';
}
