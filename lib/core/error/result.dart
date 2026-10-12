import 'failure.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
