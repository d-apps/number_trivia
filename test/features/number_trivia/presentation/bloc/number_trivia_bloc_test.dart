import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia_entity.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_event.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_state.dart';

class MockGetConcreteNumberTrivia extends Mock implements GetConcreteNumberTrivia {}
class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}
class MockInputConverter extends Mock implements InputConverter {}

void main(){

  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter = MockInputConverter();

  setUp((){

    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        inputConverter: mockInputConverter
    );

  });

  test('initialState should be Empty', (){

    expect(bloc.state, equals(EmptyState()));

  });

  // The event takes in a String
  final tNumberString = '1';

  // This is the successful output of the InputConverter
  final tNumberParsed = int.parse(tNumberString);

  // NumberTrivia instance is needed too, of course
  final tNumberTrivia = NumberTriviaEntity(number: 1, text: 'test trivia');

  void setUpMockInputConverterSuccess() =>
      when( () => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Right(tNumberParsed));

  void setUpMockGetConcreteNumberTriviaSuccess() =>
      when( () => mockGetConcreteNumberTrivia(Params(number: tNumberParsed)))
          .thenAnswer((_) async => Right(tNumberTrivia));

  group('GetTriviaForConcreteNumber', () {


    test('should call the InputConverter to validate and convert the string to an unsigned integer',
        () async {

          setUpMockInputConverterSuccess();
          setUpMockGetConcreteNumberTriviaSuccess();

          bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));

          await untilCalled( () => mockInputConverter.stringToUnsignedInteger(any()));
          verify(() => mockInputConverter.stringToUnsignedInteger(any()));


        });

    test('should emit [Error] when the input is invalid',
         () async {

      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Left(InvalidInputFailure()));

      // assert later
      final expected = [
        // initial state is always emitted first.
        //Empty(),
        ErrorState(message: INVALID_INPUT_FAILURE_MESSAGE)
      ];

      // act
      bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));

      expect(bloc.stream, emitsInOrder(expected));


    });

    test('should get data from the concrete use case',
            () async {

              setUpMockInputConverterSuccess();
              setUpMockGetConcreteNumberTriviaSuccess();

              bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));
              await untilCalled(() => mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));

              verify( () => mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));

            }
    );

    test('should emit [Loading, Loaded] when data is gotten successfully',
            () async {

          setUpMockInputConverterSuccess();
          setUpMockGetConcreteNumberTriviaSuccess();

          /*
          final expected = [
            //LoadingState(),
            LoadedState(trivia: tNumberTrivia)
          ];

          bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));

          await expectLater(bloc.state, emitsInOrder(expected));
           */

        }
    );

    test(
      'should emit [Loading, Error] when getting data fails',
          () async {

        // arrange
        setUpMockInputConverterSuccess();
        when( () => mockGetConcreteNumberTrivia(Params(number: tNumberParsed)))
            .thenAnswer((_) async => Left(ServerFailure()));

        /*
        // assert later
        final expected = [
          EmptyState(),
          LoadingState(),
          ErrorState(message: SERVER_FAILURE_MESSAGE),
        ];

        expectLater(bloc.state, emitsInOrder(expected));

        // act
        bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));
         */
      },
    );

    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
          () async {

        // arrange
        setUpMockInputConverterSuccess();

        when( () => mockGetConcreteNumberTrivia(Params(number: tNumberParsed)))
            .thenAnswer((_) async => Left(CacheFailure()));

        /*
        // assert later
        final expected = [
          EmptyState(),
          LoadingState(),
          ErrorState(message: CACHE_FAILURE_MESSAGE),
        ];

        expectLater(bloc.state, emitsInOrder(expected));

        // act
        bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));
         */
      },
    );

  });

  group('GetTriviaForRandomNumber', () {

    final tNumberTrivia = NumberTriviaEntity(number: 1, text: 'test trivia');

    test(
      'should get data from the random use case',
          () async {
        // arrange
        when( () => mockGetRandomNumberTrivia(NoParams()))
            .thenAnswer((_) async => Right(tNumberTrivia));
        // act
        bloc.add(GetTriviaForRandomNumberEvent());
        await untilCalled(() => mockGetRandomNumberTrivia(NoParams()));
        // assert
        verify(() => mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
          () async {
        // arrange
        when(() => mockGetRandomNumberTrivia(NoParams()))
            .thenAnswer((_) async => Right(tNumberTrivia));

        /*
        // assert later
        final expected = [
          EmptyState(),
          LoadingState(),
          LoadedState(trivia: tNumberTrivia),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForRandomNumberEvent());
         */
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
          () async {
        // arrange
        when(() => mockGetRandomNumberTrivia(NoParams()))
            .thenAnswer((_) async => Left(ServerFailure()));

        /*
        // assert later
        final expected = [
          EmptyState(),
          LoadingState(),
          ErrorState(message: SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForRandomNumberEvent());
         */
      },
    );

    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
          () async {
        // arrange
        when(() => mockGetRandomNumberTrivia(NoParams()))
            .thenAnswer((_) async => Left(CacheFailure()));
        // assert later
        /*
        final expected = [
          EmptyState(),
          LoadingState(),
          ErrorState(message: CACHE_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForRandomNumberEvent());
         */
      },
    );
  });

}