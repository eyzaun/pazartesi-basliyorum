import 'package:equatable/equatable.dart';

/// A sealed class representing the result of an operation.
/// Can be either [Success] or [Failure].
sealed class Result<T> extends Equatable {
  const Result();
}

/// Represents a successful result with data.
class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  List<Object?> get props => [data];

  @override
  String toString() => 'Success(data: $data)';
}

/// Represents a failed result with an error message.
class Failure<T> extends Result<T> {
  const Failure(this.message, [this.exception]);

  final String message;
  final Exception? exception;

  @override
  List<Object?> get props => [message, exception];

  @override
  String toString() => 'Failure(message: $message, exception: $exception)';
}
