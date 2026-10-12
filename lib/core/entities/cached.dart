import 'package:equatable/equatable.dart';

class Cached<T> extends Equatable {
  const Cached(this.data, {this.savedAt, this.isOutdated = false});

  final T data;
  final DateTime? savedAt;
  final bool isOutdated;

  @override
  List<Object?> get props => [data, savedAt, isOutdated];
}
