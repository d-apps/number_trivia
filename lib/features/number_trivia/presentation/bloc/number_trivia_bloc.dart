import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_event.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_state.dart';

import '../../../../core/util/input_converter.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {

  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getRandomNumberTrivia,
    required this.getConcreteNumberTrivia,
    required this.inputConverter
}) : super(EmptyState()){

    on<NumberTriviaEvent>((event, emit) async {

      if(event is GetTriviaForConcreteNumberEvent){

        final inputEither = inputConverter.stringToUnsignedInteger(event.numberString);

        await inputEither.fold(
                (failure) async {
                  emit(ErrorState(message: INVALID_INPUT_FAILURE_MESSAGE));
                },
                (integer) async {

                  emit(LoadingState());
                  final either = await getConcreteNumberTrivia(Params(number: integer));

                  await either.fold(
                          (failure) async {
                            emit(ErrorState(message:  _mapFailureToMessage(failure)));
                          },
                          (numberTrivia) async {
                            emit(LoadedState(trivia: numberTrivia));
                          }
                  );


                }
        );

      }

      else if(event is GetTriviaForRandomNumberEvent){

        emit(LoadingState());
        final failureOrTrivia = await getRandomNumberTrivia(NoParams());

        await failureOrTrivia.fold(
            (failure) async {
              emit(ErrorState(message: _mapFailureToMessage(failure)));
            },
            (numberTrivia) async {
              emit(LoadedState(trivia: numberTrivia));
            }
        );

      }

    });

  }


  String _mapFailureToMessage(Failure failure){

    switch(failure.runtimeType){
      case ServerFailure: return SERVER_FAILURE_MESSAGE;
      case CacheFailure: return CACHE_FAILURE_MESSAGE;
      default: return 'Unexpected Error';
    }

  }


}