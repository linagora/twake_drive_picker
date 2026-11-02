import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

abstract class Success extends Equatable {
  const Success();

  @override
  bool? get stringify => true;
}

abstract class Failure extends Equatable {
  const Failure();

  @override
  bool? get stringify => true;
}

abstract class FeatureFailure extends Failure {
  final dynamic exception;
  final Stream<Either<Failure, Success>>? onRetry;

  const FeatureFailure({this.exception, this.onRetry});

  @override
  List<Object?> get props => [exception, onRetry];
}

abstract class UIState extends Success {
  const UIState();
}

abstract class LoadingState extends UIState {
  const LoadingState();

  @override
  List<Object?> get props => [];
}
