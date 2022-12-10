import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/number_trivia_entity.dart';
import '../repositories/number_trivia_repository.dart';

class GetConcreteNumberTrivia extends UseCase<NumberTriviaEntity, Params>{

  final NumberTriviaRepository repository;

  GetConcreteNumberTrivia(this.repository);

  Future<Either<Failure, NumberTriviaEntity>> call(Params params) async {
    return await repository.getConcreteNumberTrivia(params.number);
  }

}