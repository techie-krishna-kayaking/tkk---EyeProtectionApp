import 'package:equatable/equatable.dart';

/// Base type for recoverable, user-presentable failures returned from the
/// repository layer. Keeps the UI free of raw exceptions.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Persistence (Hive / disk) related failure.
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Platform-channel / native integration failure.
class PlatformFailure extends Failure {
  const PlatformFailure(super.message);
}

/// Notification scheduling / permission failure.
class NotificationFailure extends Failure {
  const NotificationFailure(super.message);
}
