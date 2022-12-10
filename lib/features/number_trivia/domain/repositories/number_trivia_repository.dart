import 'package:dartz/dartz.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia_entity.dart';
import '../../../../core/error/failures.dart';

abstract class NumberTriviaRepository {
  Future<Either<Failure, NumberTriviaEntity>> getConcreteNumberTrivia(int number);
  Future<Either<Failure, NumberTriviaEntity>> getRandomNumberTrivia();
}