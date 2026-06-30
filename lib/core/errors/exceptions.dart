/// Low-level exceptions thrown by data sources. These are caught at the
/// repository boundary and converted into [Failure]s.
library;

class StorageException implements Exception {
  const StorageException(this.message);
  final String message;
  @override
  String toString() => 'StorageException: $message';
}

class PlatformChannelException implements Exception {
  const PlatformChannelException(this.message);
  final String message;
  @override
  String toString() => 'PlatformChannelException: $message';
}

class NotificationException implements Exception {
  const NotificationException(this.message);
  final String message;
  @override
  String toString() => 'NotificationException: $message';
}
