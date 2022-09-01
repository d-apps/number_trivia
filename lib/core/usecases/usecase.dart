import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia/core/error/failures.dart';

abstract class UseCase<Type, Params>{
  Future<Either<Failure, Type>> call(Params params);
}

class Params extends Equatable {
  final int number;

  Params({ required this.number});

  @override
  // TODO: implement props
  List<Object?> get props => [number];

}

class NoParams extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}